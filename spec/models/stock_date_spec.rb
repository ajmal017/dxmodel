require 'spec_helper'

describe StockDate do
  before :each do
    @stock_date = FactoryGirl.create :stock_date
  end

  describe '#calc_ma_signals' do
    before(:each) do
      MA_LONG_ENTER = false
      MA_SHORT_ENTER = false
    end
    describe "for longs" do
      it 'should not create enter signal if not required' do
        @stock_date.calc_ma_signals
        @stock_date.ma_long_enter.should be_nil
      end
      it 'should create correct enter signal' do
        MA_LONG_ENTER = true
        @stock_date = FactoryGirl.build(:stock_date, smavg_10d: 10, wmavg_10d: 20)
        @stock_date.calc_ma_signals
        @stock_date.ma_long_enter.should be_true

        @stock_date = FactoryGirl.build(:stock_date, smavg_10d: 20, wmavg_10d: 10)
        @stock_date.calc_ma_signals
        @stock_date.ma_long_enter.should be_false
      end
    end
    describe "for shorts" do
      it 'should not create enter signal if not required' do
        @stock_date.calc_ma_signals
        @stock_date.ma_short_enter.should be_nil
      end
      it 'should create correct enter signal' do
        MA_SHORT_ENTER = true
        @stock_date = FactoryGirl.build(:stock_date, smavg_10d: 20, wmavg_10d: 10)
        @stock_date.calc_ma_signals
        @stock_date.ma_short_enter.should be_true

        @stock_date = FactoryGirl.build(:stock_date, smavg_10d: 10, wmavg_10d: 20)
        @stock_date.calc_ma_signals
        @stock_date.ma_short_enter.should be_false
      end
    end
  end

  describe '#calc_rsi_signals' do
    before (:each) do
      RSI_LONG_ENTER = false
      RSI_SHORT_ENTER = false
      RSI_OVERBOUGHT = 70.0
      RSI_OVERSOLD = 35.0
    end
    describe "for longs" do
      it 'should not create enter signal if not required' do
        @stock_date = FactoryGirl.build :stock_date, rsi: 20
        @stock_date.calc_rsi_signals
        @stock_date.rsi_long_enter.should be_nil
      end
      it 'should create correct enter signal' do
        RSI_LONG_ENTER = true
        @stock_date = FactoryGirl.build(:stock_date, rsi: 20)
        @stock_date.calc_rsi_signals
        @stock_date.rsi_long_enter.should be_true

        @stock_date = FactoryGirl.build(:stock_date, rsi: 90)
        @stock_date.calc_rsi_signals
        @stock_date.rsi_long_enter.should be_false
      end
    end
    describe "for shorts" do
      it 'should not create enter signal if not required' do
        @stock_date = FactoryGirl.build :stock_date, rsi: 20
        @stock_date.calc_rsi_signals
        @stock_date.rsi_short_enter.should be_nil
      end
      it 'should create correct enter signal' do
        RSI_SHORT_ENTER = true
        @stock_date = FactoryGirl.build(:stock_date, rsi: 40)
        @stock_date.calc_rsi_signals
        @stock_date.rsi_short_enter.should be_true

        @stock_date = FactoryGirl.build(:stock_date, rsi: 20)
        @stock_date.calc_rsi_signals
        @stock_date.rsi_short_enter.should be_false
      end
    end
  end

  describe '#calc_tech_signals' do
    it "should return correct long enter signals" do
      RSI_LONG_ENTER = nil
      MA_LONG_ENTER = nil
      @stock_date = FactoryGirl.build :stock_date
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_true # No technical indicators? Assume true

      # RSI:N MA:N
      RSI_LONG_ENTER = false
      MA_LONG_ENTER = false
      @stock_date = FactoryGirl.build :stock_date
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_true # No technical indicators? Assume true


      # RSI:Y MA:N
      RSI_LONG_ENTER = true
      MA_LONG_ENTER = false
      @stock_date = FactoryGirl.build :stock_date, rsi_long_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_true

      @stock_date = FactoryGirl.build :stock_date, rsi_long_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_false


      # RSI:N MA:Y
      RSI_LONG_ENTER = false
      MA_LONG_ENTER = true
      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_true

      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_false


      # RSI:Y MA:Y
      RSI_LONG_ENTER = true
      MA_LONG_ENTER = true
      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: false, rsi_long_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_false

      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: false, rsi_long_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_false

      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: true, rsi_long_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_false

      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: true, rsi_long_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_true


      # Mixed up signals
      RSI_LONG_ENTER = true
      MA_LONG_ENTER = false
      @stock_date = FactoryGirl.build :stock_date, ma_long_enter: true, rsi_long_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_long_enter.should be_false
    end

    it "should return correct short enter signals" do
      RSI_SHORT_ENTER = nil
      MA_SHORT_ENTER = nil
      @stock_date = FactoryGirl.build :stock_date
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_true # No technical indicators? Assume true

      # RSI:N MA:N
      RSI_SHORT_ENTER = false
      MA_SHORT_ENTER = false
      @stock_date = FactoryGirl.build :stock_date
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_true # No technical indicators? Assume true


      # RSI:Y MA:N
      RSI_SHORT_ENTER = true
      MA_SHORT_ENTER = false
      @stock_date = FactoryGirl.build :stock_date, rsi_short_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_true

      @stock_date = FactoryGirl.build :stock_date, rsi_short_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_false


      # RSI:N MA:Y
      RSI_SHORT_ENTER = false
      MA_SHORT_ENTER = true
      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_true

      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_false


      # RSI:Y MA:Y
      RSI_SHORT_ENTER = true
      MA_SHORT_ENTER = true
      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: false, rsi_short_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_false

      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: false, rsi_short_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_false

      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: true, rsi_short_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_false

      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: true, rsi_short_enter: true
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_true


      # Mixed up signals
      RSI_SHORT_ENTER = true
      MA_SHORT_ENTER = false
      @stock_date = FactoryGirl.build :stock_date, ma_short_enter: true, rsi_short_enter: false
      @stock_date.calc_tech_signals
      @stock_date.tech_short_enter.should be_false

    end
  end
end

