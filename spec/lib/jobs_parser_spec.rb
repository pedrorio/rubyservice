require 'rspec'
require_relative '../../lib/jobs_parser'

describe OTB::JobsParser do

  it 'Class responds to call' do
    OTB::JobsParser.should respond_to?(:call)
  end

  describe 'validates the jobs list class' do

    it 'returns a Failure when the jobs list is not a string' do
      string_of_jobs = nil
      output = OTB::JobsParser.call(string_of_jobs)
      output.should be_an_instance_of(Dry::Monads::Result::Failure)
    end

    it 'returns a Failure when the jobs list is a string but has the wrong format' do
      string_of_jobs = 'hello world'
      ouput = OTB::JobsParser.call(string_of_jobs)
      ouput.should be_an_instance_of(Dry::Monads::Result::Failure)
    end

    it 'returns a Success when the jobs list is an empty string' do
      string_of_jobs = ''
      ouput = OTB::JobsParser.call(string_of_jobs)
      ouput.should be_an_instance_of(Dry::Monads::Result::Success)
    end

    it 'returns a Success when the jobs list is a non empty string and or it has the right format' do
      string_of_jobs = 'a => \nb => \nc => '
      ouput = OTB::JobsParser.call(string_of_jobs)
      ouput.should be_an_instance_of(Dry::Monads::Result::Success)
    end
  end

  describe 'parse' do

    describe 'when the job list is empty' do

      it 'returns an empty hash ' do
        string_of_jobs = ''
        output = OTB::JobsParser.call(string_of_jobs).success
        output.should eq({})
      end
    end

    describe 'when the job list does not have jobs with dependencies' do

      before(:all) do
        string_of_jobs = 'a => \nb => \nc => '
        @output = OTB::JobsParser.call(string_of_jobs).success
      end

      it 'returns a hash with the same number of jobs' do
        @output.size.should eq(3)
      end

      it 'returns a hash with the preceding jobs as keys and empty strings as values' do
        @output.should eq({ 'a' => '', 'b' => '', 'c' => '' })
      end
    end

    describe 'when the job list only has jobs with dependencies' do

      before(:all) do
        string_of_jobs = 'a => b\nb => c\nc => d'
        @output = OTB::JobsParser.call(string_of_jobs).success
      end

      it 'returns a hash with the same number of jobs' do
        @output.size.should eq(3)
      end

      it 'returns a hash with the preceding jobs as keys and the succeeding jobs as values' do
        @output.should eq({ 'a' => 'b', 'b' => 'c', 'c' => 'd' })
      end
    end

    describe 'when the jobs list has jobs with and without dependencies' do

      before(:all) do
        string_of_jobs = 'a => b\nb => \nc => d'
        @output = OTB::JobsParser.call(string_of_jobs).success
      end

      it 'returns a hash with the same number of jobs' do
        @output.size.should eq(3)
      end

      it 'returns a hash with the preceding jobs as keys and the succeeding jobs as values if the job exists or as an empty string' do
        @output.should eq({ 'a' => 'b', 'b' => '', 'c' => 'd' })
      end
    end
  end
end