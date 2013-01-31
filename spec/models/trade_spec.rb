require 'spec_helper'

describe Trade do
  before :each do
    @stock = FactoryGirl.create :stock
    @trade = FactoryGirl.build :trade, :long, stock: @stock
    @ten_days_ago = 10.days.ago.to_date
  end

  describe "Defaults" do
    it "should default to state 'enter_signaled'" do
      @trade = Trade.new.state.should eql('enter_signaled')
    end
  end

  describe "Associations" do
    it { should belong_to(:stock) }
    it { should have_one(:industry) }
  end


  describe "Validations" do
    describe "enter_signaled" do
      before :each do @trade.state = 'enter_signaled' end
      it { should validate_presence_of(:stock_id) }
      it { should validate_presence_of(:longshort) }
      it { should validate_presence_of(:enter_signal_date) }
    end

    describe "entered" do
      before :each do Trade.state_machine.instance_variable_set(:@initial_state, 'entered') end
      it { should validate_presence_of(:quantity) }
      it { should validate_presence_of(:enter_date) }
      it { should validate_presence_of(:enter_local_price) }
      it { should validate_presence_of(:enter_usd_fx_rate) }
      it { should validate_presence_of(:enter_local_value) }
      it { should validate_presence_of(:enter_usd_value) }
    end
  
    describe "exit_signaled" do
      before :each do Trade.state_machine.instance_variable_set(:@initial_state, 'exit_signaled') end
      it { should validate_presence_of(:exit_signal_date) }
    end

    describe "exited" do
      before :each do Trade.state_machine.instance_variable_set(:@initial_state, 'exited') end
      it { should validate_presence_of(:exit_date) }
      it { should validate_presence_of(:exit_local_price) }
      it { should validate_presence_of(:exit_usd_fx_rate) }
      it { should validate_presence_of(:exit_local_value) }
      it { should validate_presence_of(:exit_usd_value) }
    end
  end

  describe "Scopes" do
  end

  describe '#holding_period_high' do
    before :each do
      @stock = FactoryGirl.create :stock

      FactoryGirl.create :stock_date, stock: @stock, date: @ten_days_ago, close: 20.0
      FactoryGirl.create :stock_date, stock: @stock, date: 9.days.ago.to_date, close: 5.0
      FactoryGirl.create :stock_date, stock: @stock, date: 8.days.ago.to_date, close: 6.0
      FactoryGirl.create :stock_date, stock: @stock, date: 7.days.ago.to_date, close: 7.0
      FactoryGirl.create :stock_date, stock: @stock, date: 6.days.ago.to_date, close: 6.0
      FactoryGirl.create :stock_date, stock: @stock, date: 5.days.ago.to_date, close: 5.0
      FactoryGirl.create :stock_date, stock: @stock, date: 4.days.ago.to_date, close: 4.0
      FactoryGirl.create :stock_date, stock: @stock, date: 3.days.ago.to_date, close: 12.0
      FactoryGirl.create :stock_date, stock: @stock, date: 2.days.ago.to_date, close: 15.0
      FactoryGirl.create :stock_date, stock: @stock, date: 1.days.ago.to_date, close: 13.0
    end

    it "should return highest close on or after entry date and before exit date" do
      @trade = FactoryGirl.create :trade, :exited, :long, stock: @stock, enter_date: 8.days.ago.to_date, exit_date: 3.days.ago.to_date
      @trade.holding_period_high.to_f.should eql 7.0
    end
    it "should return highest close on or after entry date when not exited" do
      @trade = FactoryGirl.create :trade, :entered, :long, stock: @stock, enter_date: 8.days.ago.to_date, exit_date: nil
      @trade.holding_period_high.to_f.should eql 15.0
    end
  end

  describe '#holding_period_low' do
    before :each do
      @stock = FactoryGirl.create :stock

      FactoryGirl.create :stock_date, stock: @stock, date: @ten_days_ago, close: 20.0
      FactoryGirl.create :stock_date, stock: @stock, date: 9.days.ago.to_date, close: 5.0
      FactoryGirl.create :stock_date, stock: @stock, date: 8.days.ago.to_date, close: 6.0
      FactoryGirl.create :stock_date, stock: @stock, date: 7.days.ago.to_date, close: 7.0
      FactoryGirl.create :stock_date, stock: @stock, date: 6.days.ago.to_date, close: 5.0
      FactoryGirl.create :stock_date, stock: @stock, date: 5.days.ago.to_date, close: 8.0
      FactoryGirl.create :stock_date, stock: @stock, date: 4.days.ago.to_date, close: 9.0
      FactoryGirl.create :stock_date, stock: @stock, date: 3.days.ago.to_date, close: 15.0
      FactoryGirl.create :stock_date, stock: @stock, date: 2.days.ago.to_date, close: 12.0
      FactoryGirl.create :stock_date, stock: @stock, date: 1.days.ago.to_date, close: 3.0
    end

    it "should return lowest close between entry date and exit date" do
      @trade = FactoryGirl.create :trade, :exited, :short, stock: @stock, enter_date: 8.days.ago.to_date, exit_date: 3.days.ago.to_date
      @trade.holding_period_low.to_f.should eql 5.0
    end
    it "should return lowest close after entry date when not exited" do
      @trade = FactoryGirl.create :trade, :entered, :short, stock: @stock, enter_date: 8.days.ago.to_date, exit_date: nil
      @trade.holding_period_low.to_f.should eql 3.0
    end
  end


  describe '#stop_loss_value' do
    it 'should return 10% below holding period high for long trades' do
      @trade = FactoryGirl.create :trade, :entered, :long
      @trade.stub!(:holding_period_high).and_return(100)
      @trade.stop_loss_value.should eql 90.0
    end
    it 'should return 5% above holding period low for short trades' do
      @trade = FactoryGirl.create :trade, :entered, :short
      @trade.stub!(:holding_period_low).and_return(100)
      @trade.stop_loss_value.should eql 105.0
    end
  end

  
  describe '#stop_loss_triggered?' do
    it 'should return true if price is < stop loss value for long trade' do
      @trade = FactoryGirl.create :trade, :entered, :long
      @trade.stub!(:stop_loss_value).and_return(90)
      @trade.stop_loss_triggered?(90).should be_true
    end
    it 'should not return true if price is > stop loss value for long trade' do
      @trade = FactoryGirl.create :trade, :entered, :long
      @trade.stub!(:stop_loss_value).and_return(90)
      @trade.stop_loss_triggered?(91).should be_false
    end

    it 'should return true if price is > stop loss value for short trade' do
      @trade = FactoryGirl.create :trade, :entered, :short
      @trade.stub!(:stop_loss_value).and_return(105)
      @trade.stop_loss_triggered?(105).should be_true
    end
    it 'should not return true if price is < stop loss value for short trade' do
      @trade = FactoryGirl.create :trade, :entered, :short
      @trade.stub!(:stop_loss_value).and_return(105)
      @trade.stop_loss_triggered?(104).should be_false
    end
  end

  describe '#usd_value_on_date' do
    before :each do
      @trade.stub!(:local_value_on_date).and_return(1000)
      @fx_rate = FactoryGirl.create :fx_rate
      FxRate.stub!(:where).and_return([@fx_rate])
    end
    it 'should get the fx rates on given date' do
      FxRate.should_receive(:where).with(date: @ten_days_ago).and_return([@fx_rate])
      @trade.usd_value_on_date(@ten_days_ago)
    end
    it 'should get the local value on date' do
      @trade.should_receive(:local_value_on_date).and_return(1000.0)
      @trade.usd_value_on_date(@ten_days_ago)
    end
    it 'should use the usdsgd rate if trade is for Singapore stock' do
      @stock.stub!(:country).and_return('SP')
      @fx_rate.should_receive(:usdsgd).and_return(2)
      @trade.usd_value_on_date(@ten_days_ago)
    end
    it 'should use the usdhkd rate if trade is for Hong Kong stock' do
      @stock.stub!(:country).and_return('HK')
      @fx_rate.should_receive(:usdhkd).and_return(2)
      @trade.usd_value_on_date(@ten_days_ago)
    end
  end

  describe '#local_value_on_date' do
    it "should get price on date" do
      @stock.should_receive(:price_on_date).with(@ten_days_ago).and_return(10)
      @trade.local_value_on_date(@ten_days_ago)
    end
    it "should multiply price on date by quantity" do
      @stock.stub!(:price_on_date).and_return(10)
      @trade.quantity = 10
      @trade.local_value_on_date(@ten_days_ago).should eql 100
    end
  end

  describe '#usd_pnl_on_date date' do
    describe 'for a long trade' do
      it 'should return correct value for exited trade' do
        @trade = FactoryGirl.build :trade, :exited, :long, stock: @stock, enter_usd_value: 500.0, exit_usd_value: 1000.0
        @trade.stub!(:usd_value_on_date).and_return(1500.0)
        @trade.usd_pnl_on_date(@ten_days_ago).to_f.should eql 500.0
      end
      it 'should return correct value for not exited trade' do
        @trade = FactoryGirl.build :trade, :entered, :long, stock: @stock, enter_usd_value: 500.0, exit_usd_value: 1000.0
        @trade.stub!(:usd_value_on_date).and_return(1500.0)
        @trade.usd_pnl_on_date(@ten_days_ago).to_f.should eql 1000.0
      end
    end
    describe 'for a short trade' do
      it 'should return correct value for exited trade' do
        @trade = FactoryGirl.build :trade, :exited, :short, stock: @stock, enter_usd_value: 500.0, exit_usd_value: 1000.0
        @trade.stub!(:usd_value_on_date).and_return(1500.0)
        @trade.usd_pnl_on_date(@ten_days_ago).to_f.should eql -500.0
      end
      it 'should return correct value for not exited trade' do
        @trade = FactoryGirl.build :trade, :entered, :short, stock: @stock, enter_usd_value: 500.0, exit_usd_value: 1000.0
        @trade.stub!(:usd_value_on_date).and_return(1500.0)
        @trade.usd_pnl_on_date(@ten_days_ago).to_f.should eql -1000.0
      end
    end
  end
end
