class TextAnalyzer
  SYSTEM_PROMPT = <<~PROMPT
    あなたは日本語テキストの構造を分析するアシスタントです。
    与えられたテキストについて、以下の 6 要素 (5W1H) が
    それぞれ明確に含まれているかどうかを判定してください。

    - who: 誰が
    - when: いつ
    - what: 何をするか / したか
    - where: どこで
    - why: なぜ（目的や理由）
    - how: どのように（手段や方法）
  PROMPT

  ELEMENT_SCHEMA = {
    type: "object",
    properties: {
      present: { type: "boolean", description: "要素が含まれているかどうか" },
      confidence: { type: "number", description: "確信度 (0.0〜1.0)" },
      value: { type: %w[string null], description: "抜き出した短いフレーズ（なければnull）" },
      note: { type: "string", description: "そう判断した理由（日本語・短め）" }
    },
    required: %w[present confidence value note],
    additionalProperties: false
  }.freeze

  RESPONSE_SCHEMA = {
    type: "json_schema",
    json_schema: {
      name: "five_w_one_h_analysis",
      strict: true,
      schema: {
        type: "object",
        properties: {
          who: ELEMENT_SCHEMA,
          when: ELEMENT_SCHEMA,
          what: ELEMENT_SCHEMA,
          where: ELEMENT_SCHEMA,
          why: ELEMENT_SCHEMA,
          how: ELEMENT_SCHEMA
        },
        required: %w[who when what where why how],
        additionalProperties: false
      }
    }
  }.freeze

  def initialize(text)
    @text = text
    @client = OpenAI::Client.new(api_key: Rails.application.credentials.openai.api_key)
  end

  def call
    response = @client.chat.completions.create(
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: @text }
      ],
      response_format: RESPONSE_SCHEMA
    )

    content = response.choices[0].message.content
    JSON.parse(content, symbolize_names: true)
  end
end
