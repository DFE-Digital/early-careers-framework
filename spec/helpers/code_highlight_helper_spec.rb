# frozen_string_literal: true

require "rails_helper"

describe CodeHighlightHelper, type: :helper do
  describe ".highlight_with_lexer" do
    let(:source) { "foo bar" }
    let(:lexer) { ::Rouge::Lexers::PlainText.new }

    subject { highlight_with_lexer(lexer, source) }

    it "renders HTML to highlight the source" do
      is_expected.to eq(
        <<~HTML.chomp,
          <pre><code>foo bar</code></pre>
        HTML
      )
    end

    context "when the formatter outputs malicious tags" do
      before do
        malicious_formatter = instance_double(Rouge::Formatters::HTML)
        allow(Rouge::Formatters::HTML).to receive(:new) { malicious_formatter }
        allow(malicious_formatter).to receive(:format) { "<script>alert('boo!')</script>" }
      end

      it "removes malicious HTML" do
        is_expected.to eq(
          <<~HTML.chomp,
            <pre><code>alert('boo!')</code></pre>
          HTML
        )
      end
    end
  end

  describe ".highlight_as_json" do
    let(:obj) { { foo: :bar } }

    subject { highlight_as_json(obj) }

    it "renders HTML to highlight the JSON" do
      is_expected.to eq(
        <<~HTML.chomp,
          <pre><code><span class="p">{</span><span class="w">
            </span><span class="nl">"foo"</span><span class="p">:</span><span class="w"> </span><span class="s2">"bar"</span><span class="w">
          </span><span class="p">}</span></code></pre>
        HTML
      )
    end
  end

  describe ".highlight_as_plain_text" do
    let(:text) { "some\rtext" }

    subject { highlight_as_plain_text(text) }

    it "renders HTML to highlight the text" do
      is_expected.to eq(
        <<~HTML.chomp,
          <pre><code>some\rtext</code></pre>
        HTML
      )
    end
  end
end
