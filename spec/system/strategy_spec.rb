require 'spec_helper'
require_relative "../../models/strategy"
require_relative "../../models/indicator"
require_relative "../../models/user"

describe "Strategy" do
  let(:user) { create(:user, name: "Pipo", email: "pipo@gmail.com") }
  let(:strategy) { create(:strategy, name: "piposplan", user: user) }

  describe "RSI required" do
    let(:indicator) { Indicator.find_by(indicator_symbol: "rsi") }
    let(:fileset) { "./spec/fixtures/daily_IBM.csv" }
    let(:mark) { create(:mark, strategy: strategy, indicator: indicator, fileset: fileset, required: true) }
    let(:date_format) { /[^\d{4}\/\d{1,2}\/\d{1,2}]/ }

    before { strategy.marks << mark }

    context "when no limit applies" do
      it "computed_required returns all computed values" do
        expect(strategy.computed_required.sample.rsi).not_to be_nil
      end

      it "computed_non_required is empty" do
        expect(strategy.computed_non_required.empty?).to be_truthy
      end

      it "required_dates_count should return hash with date => count" do
        required_dates_count = strategy.required_dates_count
        date_key = required_dates_count.keys.sample
        expect(date_key =~ date_format).not_to be_nil
        expect(required_dates_count[date_key]).to eq(1)
      end

      it "non_required_dates_count should be nil" do
        expect(strategy.non_required_dates_count.empty?).to be_truthy
      end

      context "#filter" do
        let(:filtered) { strategy.filter }

        it "should return all computed_required dates" do
          expect(filtered.count).to eq(strategy.required_dates_count.keys.count)
        end

        it "should return an Array" do
          expect(filtered.class.to_s).to eq("Array")
        end

        it "should return an array of dates" do
          expect(filtered.first =~ date_format).not_to be_nil
        end
      end
    end
    context "when limits are applied" do
      let(:limit) { { name: "rsi", operation: ">", value: 60 } }
      let(:limit2) { { name: "rsi", operation: "<", value: 70 } }
      let(:results_count) { 8 } # checked manually, daily_IBM rsi returns 8 results > 60

      context "with one limit" do
        before do
          mark.limits << limit
          mark.save
        end
  
        it "computed_required should return only matching results" do
          expect(strategy.computed_required.count).to eq(results_count)
        end
  
        describe "#filter" do
          let(:required_dates) { strategy.required_dates }
  
          it "required_dates should return filtered dates" do
            expect(required_dates.count).to eq(results_count)
          end
  
          it "required_dates should be an array of dates" do
            expect(required_dates.first =~ date_format).not_to be_nil
          end
  
          it "should match required_dates" do
            expect(strategy.filter).to eq(required_dates)
          end
        end
      end

      context "with more than one limit" do
        before do
          mark.limits << limit
          mark.limits << limit2
          mark.save
        end

        it "should return only elements matching both limits" do
          expect(strategy.filter.count).to eq(7)
        end
      end
    end
  end

  describe "RSI not required" do
    let(:indicator) { Indicator.find_by(indicator_symbol: "rsi") }
    let(:fileset) { "./spec/fixtures/daily_IBM.csv" }
    let(:mark) { create(:mark, strategy: strategy, indicator: indicator, fileset: fileset, required: false) }
    let(:date_format) { /[^\d{4}\/\d{1,2}\/\d{1,2}]/ }

    before { strategy.marks << mark }

    it "computed_required is empty" do
      expect(strategy.computed_required.empty?).to be_truthy
    end

    it "computed_non_required returns all computed values" do
      expect(strategy.computed_non_required.sample.rsi).not_to be_nil
    end

    context "#filter" do
      let(:filtered) { strategy.filter }

      it "should return an Array" do
        expect(filtered.class.to_s).to eq("Array")
      end

      it "should return an array of dates" do
        expect(filtered.first =~ date_format).not_to be_nil
      end
    end

    context "when limits apply" do
      let(:limit) { { name: "rsi", operation: ">", value: 60 } }
      let(:results_count) { 8 } # checked manually, daily_IBM rsi returns 8 results > 60

      before do
        mark.limits << limit
        mark.save
      end

      describe "#filter" do
        let(:non_required_dates_count) { strategy.non_required_dates_count }
        let(:filtered) { strategy.filter }

        it "should match non_required_dates" do
          expect(filtered).to eq(non_required_dates_count.keys)
        end

        it "should match non_required_dates" do
          expect(filtered.count).to eq(results_count)
        end
      end
    end
  end

  describe "RSI required - MACD required" do
    let(:rsi) { Indicator.find_by(indicator_symbol: "rsi") }
    let(:macd) { Indicator.find_by(indicator_symbol: "macd") }
    let(:fileset) { "./spec/fixtures/daily_IBM.csv" }
    let(:mark1) { create(:mark, strategy: strategy, indicator: rsi, fileset: fileset, required: true) }
    let(:mark2) { create(:mark, strategy: strategy, indicator: macd, fileset: fileset, required: true) }
    let(:date_format) { /[^\d{4}\/\d{1,2}\/\d{1,2}]/ }

    context "when limits apply" do
      let(:rsi_limit) { { name: "rsi", operation: ">", value: 60 } }
      let(:macd_limit) { { name: "macd_line", operation: ">", value: 1.3 } }
      let(:results_count) { 8 } # checked manually, daily_IBM rsi returns 8 results > 60

      before do
        mark1.limits << rsi_limit
        mark2.limits << macd_limit
        mark1.save
        mark2.save
        strategy.marks << mark1
        strategy.marks << mark2
      end

      describe "#filter" do
        let(:filtered) { strategy.filter }

        it "should return an Array of dates" do
          expect(filtered.first =~ date_format).not_to be_nil
        end

        it "should return only results matching limits" do
          expect(filtered.count).to eq(6)
        end
      end
    end
  end

  describe "RSI required - MACD not required" do
    let(:rsi) { Indicator.find_by(indicator_symbol: "rsi") }
    let(:macd) { Indicator.find_by(indicator_symbol: "macd") }
    let(:fileset) { "./spec/fixtures/daily_IBM.csv" }
    let(:mark1) { create(:mark, strategy: strategy, indicator: rsi, fileset: fileset, required: true) }
    let(:mark2) { create(:mark, strategy: strategy, indicator: macd, fileset: fileset, required: false) }
    let(:date_format) { /[^\d{4}\/\d{1,2}\/\d{1,2}]/ }

    context "when min_buy_required is set" do
      let(:rsi_limit) { { name: "rsi", operation: ">", value: 60 } }
      let(:macd_limit) { { name: "macd_line", operation: ">", value: 1.3 } }
      let(:results_count) { 8 } # checked manually, daily_IBM rsi returns 8 results > 60

      before do
        mark1.limits << rsi_limit
        mark2.limits << macd_limit
        mark1.save
        mark2.save
        strategy.marks << mark1
        strategy.marks << mark2
      end

      describe "at 2" do
        let(:filtered) { strategy.filter }

        before { strategy.min_buy_required = 2 }

        it "#filter should return only results matching limits" do
          expect(filtered.count).to eq(6)
        end
      end

      describe "at 1" do
        let(:filtered) { strategy.filter }

        before { strategy.min_buy_required = 1 }

        it "#filter should return all required results" do
          expect(filtered.count).to eq(8)
        end
      end
    end
  end
end
