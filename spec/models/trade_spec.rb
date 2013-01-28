require 'spec_helper'

describe Trade do
  before :each do
    @trade = FactoryGirl.build :trade
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

      FactoryGirl.create :stock_date, stock: @stock, date: 10.days.ago.to_date, close: 20.0
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

      FactoryGirl.create :stock_date, stock: @stock, date: 10.days.ago.to_date, close: 20.0
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
      @trade.should_receive(:holding_period_high).at_least(1).times.and_return(100)
      @trade.stop_loss_value.should eql 90.0
    end
    it 'should return 5% above holding period low for short trades' do
      @trade = FactoryGirl.create :trade, :entered, :short
      @trade.should_receive(:holding_period_low).at_least(1).times.and_return(100)
      @trade.stop_loss_value.should eql 105.0
    end
  end

end

