require "./spec_helper"

describe Concurrency::Future do
  describe "#supply_async" do
    it "works" do
      future = Concurrency::Future.supply_async(->() { 1 })

      future.get.should eq 1
      future.get.should eq 1
    end

    it "raises exception if raised in the supplied function" do
      future = Concurrency::Future.supply_async(Proc(Int32).new { raise Exception.new })
      expect_raises(Exception) { future.get }
    end
  end

  describe "#then" do
    it "applies functions to result" do
      future = Concurrency::Future.supply_async(->() { 1 })
        .then(->(x : Int32) { x + 1 } )
        .then(->(x : Int32) { x * 2 } )
        .then(->(x : Int32) { "Result: #{x}" } )

      future.get.should eq "Result: 4"
    end
  end

  describe "#then_async" do
    it "applies functions to result asynchronously" do
      future = Concurrency::Future.supply_async(->() { 1 })
        .then_async(->(x : Int32) { x + 1 } )

      future.get.should eq 2
    end
  end

  futures = [
    Concurrency::Future.supply_async(->() { 1 }),
    Concurrency::Future.supply_async(->() { 1 }),
    Concurrency::Future.supply_async(->() { 1 }),
    Concurrency::Future.supply_async(->() { 1 })
  ]

  describe "#then_combine" do
    it "applies function to result of both futures" do
      future = futures.reduce { |a, b| a.then_combine(b, ->(x: Int32, y : Int32) { x + y }) }
      future.get.should eq 4
    end
  end

  describe "#then_combine_async" do
    it "applies function to result of both futures asynchronously" do
      future = futures.reduce { |a, b| a.then_combine_async(b, ->(x: Int32, y : Int32) { x + y }) }
      future.get.should eq 4
    end
  end
end
