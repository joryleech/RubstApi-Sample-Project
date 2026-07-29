# frozen_string_literal: true

require "json"
require "net/http"

BASE_URL = URI(ENV.fetch("BASE_URL", "http://127.0.0.1:8000"))

def request(method, path, json: nil)
  uri = BASE_URL + path
  request_class = Net::HTTP.const_get(method.capitalize)
  request = request_class.new(uri)
  if json
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(json)
  end
  Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
end

checks = [
  ["root", request("get", "/"), 200],
  ["list items", request("get", "/items"), 200],
  ["typed path and query", request("get", "/items/1?q=demo"), 200],
  ["not found", request("get", "/items/99"), 404],
  ["create item", request("post", "/items", json: { name: "Book", price: 12.5 }), 201],
  ["validation error", request("post", "/items", json: { name: "x", price: -1 }), 422],
  ["OpenAPI", request("get", "/openapi.json"), 200],
  ["Swagger UI", request("get", "/docs"), 200]
]

failures = checks.reject { |_, response, expected| response.code.to_i == expected }
checks.each do |name, response, expected|
  marker = response.code.to_i == expected ? "PASS" : "FAIL"
  puts "#{marker} #{name}: expected #{expected}, received #{response.code}"
end

abort "#{failures.length} smoke test(s) failed" unless failures.empty?
