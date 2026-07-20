#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "openssl"
require "time"
require "uri"
require "jwt"

required = %w[ASC_ISSUER_ID ASC_KEY_ID ASC_KEY_FILE APP_IDENTIFIER]
missing = required.select { |key| ENV[key].to_s.strip.empty? }
abort "Missing required env vars: #{missing.join(', ')}" unless missing.empty?
abort "ASC_KEY_FILE does not exist: #{ENV.fetch("ASC_KEY_FILE")}" unless File.exist?(ENV.fetch("ASC_KEY_FILE"))

private_key = OpenSSL::PKey.read(File.read(ENV.fetch("ASC_KEY_FILE")))
TOKEN = JWT.encode(
  { iss: ENV.fetch("ASC_ISSUER_ID"), exp: Time.now.to_i + 20 * 60, aud: "appstoreconnect-v1" },
  private_key,
  "ES256",
  kid: ENV.fetch("ASC_KEY_ID")
)

def request_json(method, path, query: {}, body: nil)
  uri = URI("https://api.appstoreconnect.apple.com#{path}")
  uri.query = URI.encode_www_form(query) unless query.empty?
  request = Object.const_get("Net::HTTP::#{method.capitalize}").new(uri)
  request["Authorization"] = "Bearer #{TOKEN}"
  request["Content-Type"] = "application/json" if body
  request.body = JSON.generate(body) if body
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  parsed = response.body.to_s.empty? ? {} : JSON.parse(response.body)
  return parsed if response.is_a?(Net::HTTPSuccess)

  abort "ASC API #{response.code} #{method.upcase} #{uri}: #{JSON.pretty_generate(parsed["errors"] || parsed)}"
end

def get_json(path, query = {})
  request_json("get", path, query: query)
end

def post_json(path, body)
  request_json("post", path, body: body)
end

app = get_json(
  "/v1/apps",
  {
    "filter[bundleId]" => ENV.fetch("APP_IDENTIFIER"),
    "include" => "ciProduct",
    "fields[apps]" => "name,bundleId,ciProduct",
    "fields[ciProducts]" => "name,createdDate"
  }
).fetch("data").first
abort "No App Store Connect app found for #{ENV.fetch("APP_IDENTIFIER")}" unless app

ci_product_id = app.dig("relationships", "ciProduct", "data", "id")
if ci_product_id.nil?
  puts JSON.pretty_generate(
    checkedAt: Time.now.iso8601,
    app: {
      id: app.fetch("id"),
      name: app.dig("attributes", "name"),
      bundleId: app.dig("attributes", "bundleId")
    },
    ciProduct: nil,
    nextStep: "Enable the first Xcode Cloud workflow in Xcode/App Store Connect UI; public ASC API cannot create the initial ciProduct."
  )
  exit 2
end

workflows = get_json(
  "/v1/ciProducts/#{ci_product_id}/workflows",
  { "limit" => "20", "fields[ciWorkflows]" => "name,isEnabled,lastModifiedDate" }
).fetch("data")

workflow = workflows.find { |row| row.dig("attributes", "isEnabled") } || workflows.first
abort "ciProduct #{ci_product_id} has no workflows" unless workflow

triggered = nil
if ENV["TRIGGER_XCODE_CLOUD"] == "1"
  repository = get_json("/v1/ciWorkflows/#{workflow.fetch("id")}/repository").fetch("data")
  refs = get_json(
    "/v1/scmRepositories/#{repository.fetch("id")}/gitReferences",
    { "limit" => "200" }
  ).fetch("data")
  branch = refs.find {
    |row| row.dig("attributes", "name") == ENV.fetch("XCODE_CLOUD_BRANCH", "main")
  }
  abort "No git reference for branch #{ENV.fetch("XCODE_CLOUD_BRANCH", "main")}" unless branch

  triggered = post_json(
    "/v1/ciBuildRuns",
    {
      data: {
        type: "ciBuildRuns",
        attributes: { clean: true },
        relationships: {
          workflow: { data: { type: "ciWorkflows", id: workflow.fetch("id") } },
          sourceBranchOrTag: {
            data: { type: "scmGitReferences", id: branch.fetch("id") }
          }
        }
      }
    }
  ).fetch("data")
end

build_runs = get_json(
  "/v1/ciWorkflows/#{workflow.fetch("id")}/buildRuns",
  {
    "limit" => "5",
    "fields[ciBuildRuns]" =>
      "number,executionProgress,completionStatus,sourceCommit,startReason,createdDate"
  }
).fetch("data")

puts JSON.pretty_generate(
  checkedAt: Time.now.iso8601,
  app: {
    id: app.fetch("id"),
    name: app.dig("attributes", "name"),
    bundleId: app.dig("attributes", "bundleId")
  },
  ciProduct: { id: ci_product_id },
  workflows: workflows.map {
    |row| {
      id: row.fetch("id"),
      name: row.dig("attributes", "name"),
      enabled: row.dig("attributes", "isEnabled")
    }
  },
  triggeredBuildRun: triggered && {
    id: triggered.fetch("id"),
    number: triggered.dig("attributes", "number")
  },
  recentBuildRuns: build_runs.map do |row|
    attrs = row.fetch("attributes")
    {
      id: row.fetch("id"),
      number: attrs["number"],
      progress: attrs["executionProgress"],
      completion: attrs["completionStatus"],
      commit: attrs.dig("sourceCommit", "commitSha"),
      message: attrs.dig("sourceCommit", "message")
    }
  end
)
