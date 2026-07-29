# frozen_string_literal: true

require "rubst_api"

class Item < RubstApi::Model
  field :name, String, min_length: 2
  field :price, Float, gt: 0
  field :in_stock, :boolean, default: true
end

ITEMS = [
  Item.new(name: "Mechanical Keyboard", price: 129.0),
  Item.new(name: "Ruby Mug", price: 18.5, in_stock: false)
].freeze

APP = RubstApi::App.new(
  title: "RubstAPI Sample Project",
  description: "A production-shaped example of typed Ruby APIs, automatic validation, and OpenAPI documentation.",
  version: "1.0.0"
)

APP.get("/") do
  RubstApi::HTMLResponse.new(<<~HTML)
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>RubstAPI Sample Project</title>
        <style>
          :root { color-scheme: dark; font-family: Inter, ui-sans-serif, system-ui, sans-serif; }
          * { box-sizing: border-box; }
          body { margin: 0; min-height: 100vh; background: #07111f; color: #e8f0f7; }
          main { width: min(980px, calc(100% - 40px)); margin: 0 auto; padding: 88px 0; }
          .eyebrow { color: #36d399; font-size: 14px; font-weight: 800; letter-spacing: .14em; text-transform: uppercase; }
          h1 { max-width: 760px; margin: 16px 0; font-size: clamp(48px, 8vw, 88px); line-height: .98; letter-spacing: -.05em; }
          .lead { max-width: 680px; color: #9fb2c5; font-size: 21px; line-height: 1.65; }
          .actions { display: flex; flex-wrap: wrap; gap: 12px; margin: 34px 0 60px; }
          a { padding: 13px 18px; border: 1px solid #294158; border-radius: 10px; color: #e8f0f7; font-weight: 700; text-decoration: none; }
          a.primary { border-color: #36d399; background: #36d399; color: #052015; }
          .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
          .card { padding: 22px; border: 1px solid #1d3348; border-radius: 14px; background: #0d1b2a; }
          .card strong { display: block; margin-bottom: 8px; font-size: 17px; }
          .card span { color: #8fa5b8; line-height: 1.5; }
          code { color: #65e6b4; }
          @media (max-width: 720px) { .grid { grid-template-columns: 1fr; } main { padding: 52px 0; } }
        </style>
      </head>
      <body>
        <main>
          <div class="eyebrow">Ruby • Rack • OpenAPI 3.1</div>
          <h1>Typed APIs.<br>Ruby elegance.</h1>
          <p class="lead">
            A complete RubstAPI example with request validation, response models,
            automatic OpenAPI documentation, Docker Compose, and smoke tests.
          </p>
          <div class="actions">
            <a class="primary" href="/docs">Explore Swagger UI</a>
            <a href="/redoc">Read ReDoc</a>
            <a href="/openapi.json">View OpenAPI JSON</a>
          </div>
          <section class="grid">
            <div class="card"><strong>Typed parameters</strong><span>Path, query, and JSON body values are coerced before endpoint code runs.</span></div>
            <div class="card"><strong>Validation</strong><span>Invalid input receives a structured <code>422</code> response automatically.</span></div>
            <div class="card"><strong>One source of truth</strong><span>Models drive runtime validation and OpenAPI schemas together.</span></div>
          </section>
        </main>
      </body>
    </html>
  HTML
end

APP.get("/health") do
  { status: "ok" }
end

APP.get("/items/{item_id}", params: {
  item_id: RubstApi.Path(Integer, ge: 1),
  q: RubstApi.Query(String, required: false, max_length: 50)
}) do |item_id:, q:|
  item = ITEMS.fetch(item_id - 1) do
    raise RubstApi::HTTPException.new(status_code: 404, detail: "Item not found")
  end
  { item_id:, q:, item: item.model_dump }
end

APP.get("/items", response_model: { array: Item }) do
  ITEMS
end

APP.post("/items", params: {
  item: RubstApi.Body(Item)
}, response_model: Item, status_code: RubstApi::Status::HTTP_201_CREATED) do |item:|
  item
end
