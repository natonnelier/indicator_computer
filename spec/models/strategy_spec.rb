require 'spec_helper'
require_relative "../../models/strategy"
require_relative "../../models/indicator"
require_relative "../../models/user"

describe Strategy, type: :model do
  let(:user) { create(:user, name: "Pipo", email: "pipo@gmail.com") }

  describe "Instance Methods" do
    describe "instanciate object" do
      let(:strategy) { create(:strategy, name: "somename") }
      let(:indicators) { Indicator.limit(6) }

      before { indicators.each { |i| strategy.indicators << i } }

      it "includes attributes correctly" do
        expect(strategy.name).to eq("somename")
      end

      it "includes associated indicators" do
        expect(strategy.indicators.count).to eq(6)
      end
    end

    describe "instance and filter methods" do
      let(:required) { Indicator.first(2) }
      let(:non_required) { Indicator.last(4) }
      let(:strategy) { create(:strategy, name: "piposplan", user: user) }

      before do
        required.each { |i| strategy.marks.create(indicator_id: i.id, required: true) }
        non_required.each { |i| strategy.marks.create(indicator_id: i.id) }
      end

      it "returns indicators" do
        expect(strategy.indicators.count).to eq(6)
      end

      it "returns required_marks" do
        expect(strategy.marks.required.count).to eq(2)
      end

      it "returns non_required_marks" do
        expect(strategy.marks.non_required.count).to eq(4)
      end

      describe "#computed_required" do
        it "returns Array with the indicators computed" do
          expect(strategy.computed_required.class).to eq(Array)
        end

        it "returns indicators values" do
          expect(
            strategy.computed_required.first.send(required.last.indicator_symbol)
          ).not_to be_nil
        end
      end

      describe "#computed_non_required" do
        it "computed_non_required returns an Array with non_required indicators" do
          expect(strategy.computed_non_required.class).to eq(Array)
        end

        it "returns indicators values" do
          expect(
            strategy.computed_non_required.first.send(non_required.last.indicator_symbol)
          ).not_to be_nil
        end
      end

      describe "#required_dates" do
        it "returns Array of dates from required" do
          expect(strategy.required_dates.class.to_s).to eq("Array")
        end

        it "returns required dates" do
          first_required = required.first.calculate.first
          expect(strategy.required_dates.first).to eq(first_required.date_time)
        end

        it "values are uniq" do
          dates = strategy.required_dates_count
          expect(dates.count).to eq(dates.uniq.count)
        end
      end

      describe "#required_dates_count" do
        it "returns Hash of dates - count" do
          expect(strategy.required_dates_count.class.to_s).to eq("Hash")
        end

        it "returns non_required dates with count" do
          first_required = required.first.calculate.first
          expect(strategy.required_dates_count[first_required.date_time]).not_to be_nil
        end
      end

      describe "#non_required_dates_count" do
        it "returns Hash of dates - count" do
          expect(strategy.non_required_dates_count.class.to_s).to eq("Hash")
        end

        it "returns non_required dates with count" do
          first_non_required = non_required.sample.calculate.first
          expect(strategy.non_required_dates_count[first_non_required.date_time]).not_to be_nil
        end
      end
    end
  end
end