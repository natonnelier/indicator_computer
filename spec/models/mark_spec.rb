require 'spec_helper'
require_relative "../../models/mark"
require_relative "../../models/indicator"

describe Mark, type: :model do
  let(:user) { create(:user, name: "Pipo", email: "pipo@gmail.com") }
  let(:strategy) { create(:strategy, name: "Foo") }
  
  describe "model object" do
    let(:indicator) { Indicator.first }
    let(:mark) { build(:mark, strategy: strategy, indicator: indicator) }

    context "is valid" do
      it "if limits are empty" do
        expect(mark.valid?).to eq(true)
      end

      it "if limits name matches indicator response" do
        limit_key = indicator.response_keys.last
        mark.limits << { name: limit_key, operation: ">", value: 40 }
        expect(mark.limits.count).to eq(1)
        expect(mark.valid?).to eq(true)
      end
    end

    context "is invalid" do
      it "if limits name do not match indicator response" do
        mark.limits << { name: "invalid", operation: ">", value: 40 }
        expect(mark.limits.count).to eq(1)
        expect(mark.valid?).to eq(false)
      end
    end
  end

  describe "computed_results" do
    let(:indicator) { Indicator.find_by(indicator_symbol: "rsi") }
    let(:fileset) { "./spec/fixtures/daily_IBM.csv" }
    let(:mark) { create(:mark, strategy: strategy, indicator: indicator, fileset: fileset) }

    it "should return an array of computed indicators" do
      expect(mark.computed_results).to be_a(Array)
    end

    it "should include computed values" do
      expect(mark.computed_results.first.rsi).not_to be_nil
    end
  end

  describe "filter_computed" do
    let(:indicator) { Indicator.find_by(indicator_symbol: "rsi") }
    let(:fileset) { "./spec/fixtures/daily_IBM.csv" }
    let(:mark) { create(:mark, strategy: strategy, indicator: indicator, fileset: fileset) }

    it "returns all computed_values if no limit applies" do
      computed_count = mark.computed_results.count
      expect(mark.filter_computed.count).to eq(computed_count)
    end

    context "when limits are set" do
      let(:val1) { 60 }
      let(:val2) { 70 }
      let(:limit1) { { name: "rsi", operation: ">", value: val1 } }
      let(:limit2) { { name: "rsi", operation: "<", value: val2 } }
      let(:result_limit1) { 8 }
      let(:result_limits) { 7 }

      context "single limits" do
        before { mark.limits << limit1 }
  
        it "returns filtered by single limit" do
          expect(mark.filter_computed.count).to eq(result_limit1)
        end
      end

      context "multiple limits" do
        before do
          mark.limits << limit1
          mark.limits << limit2
        end
  
        it "returns filtered by all limits" do
          expect(mark.filter_computed.count).to eq(result_limits)
        end
      end
    end
  end
end