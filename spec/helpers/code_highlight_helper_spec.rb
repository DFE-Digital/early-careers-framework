# frozen_string_literal: true

require "rails_helper"

describe CodeHighlightHelper, type: :helper do
  describe ".highlight_as_json" do
    let(:obj) { { foo: :bar } }

    subject { highlight_as_json(obj) }

    it "renders HTML to highlight the JSON" do
      is_expected.to eq(
        <<~HTML.chomp,
          <pre class="app-json-code-sampe"><code><span class="p">{</span><span class="w">
            </span><span class="nl">"foo"</span><span class="p">:</span><span class="w"> </span><span class="s2">"bar"</span><span class="w">
          </span><span class="p">}</span></code></pre>
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
            <pre class="app-json-code-sampe"><code>alert('boo!')</code></pre>
          HTML
        )
      end
    end
  end
end
