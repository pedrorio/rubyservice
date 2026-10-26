require 'rspec'

require_relative '../../lib/jobs_sequencer'
require_relative '../../lib/jobs_parser'

describe OTB::JobsSequencer do

  it 'Class responds to call' do
    OTB::JobsSequencer.should respond_to?(:call)
  end

  describe 'validates the jobs hash class' do

    it 'returns a Failure when the jobs hash is not an hash' do
      jobs_hash = "hello world"
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash)
      output.should be_an_instance_of(Dry::Monads::Result::Failure)
    end

    it 'returns a Success when the jobs hash is a hash' do
      jobs_hash =  { a: '' }
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash)
      output.should be_an_instance_of(Dry::Monads::Result::Success)
    end
  end

  describe 'when the jobs hash is empty' do

    it 'returns an empty string' do
      jobs_hash = {}
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.should be_empty
    end
  end
  
  describe 'when the job hash has a single job a' do
    it 'returns a' do
      jobs_hash = {'a' => ''}
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.should eq('a')
    end
  end

  describe 'when the job hash does not have jobs with dependencies ({ \'a\' => '', \'b\' => \'\', \'c\' => \'\'  })' do
    it 'returns abc' do
      job_hash = { 'a' => '', 'b' => '', 'c' => ''  }
      output = OTB::JobsSequencer.call(jobs_hash: job_hash).success
      output.should eq('abc')
    end
  end

  describe 'when the job hash has jobs with dependencies ({ \'a\' => '', \'b\' => \'c\', \'c\' => \'\'  })' do

    before(:all) do
      jobs_hash = { 'a' => '', 'b' => 'c', 'c' => ''  }
      @output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
    end

    it 'returns acb' do
      @output.should eq('acb')
    end

    it 'positions c before b' do
      @output.index('c').should be < @output.index('b')
    end

    it 'returns the same number of jobs' do
      @output.size.should eq(3)
    end
  end

  describe 'when the job hash has jobs with and without dependencies ({ \'a\' => '', \'b\' => \'c\', \'c\' => \'f\', \'d\' => \'a\', \'e\' => \'b\', \'f\' => \'\'  })' do

    before(:all) do
      jobs_hash = {  'a' => '', 'b' => 'c', 'c' => 'f', 'd' => 'a', 'e' => 'b', 'f' => ''  }
      @output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
    end

    it 'returns the same number of jobs' do
      @output.size.should eq(6)
    end

    it 'returns a string with afdcbe' do
      @output.should eq('afdcbe')
    end

    it 'positions f before c' do
      @output.index('f').should be < @output.index('c')
    end

    it 'positions c before b' do
      @output.index('c').should be < @output.index('b')
    end

    it 'positions b before e' do
      @output.index('b').should be < @output.index('e')
    end

    it 'positions a before d' do
      @output.index('a').should be < @output.index('d')
    end
  end

  describe 'when the job hash has self dependencies ({ \'a\' => '', \'b\' => \'b\', \'c\' => \'\' })' do

    before(:all) do
      jobs_hash =  {  'a' => '', 'b' => 'b', 'c' => '' }
      @output = OTB::JobsSequencer.call(jobs_hash: jobs_hash)
    end

    it 'returns a Failure' do
      @output.should be_an_instance_of(Dry::Monads::Result::Failure)
    end

    it 'returns an OTB::JobsSequencer::SelfDependencyError' do
      @output.failure.should be_an_instance_of(OTB::JobsSequencer::SelfDependencyError)
      @output.failure.message.should eq('Jobs can’t depend on themselves')
    end
  end

  describe 'when the job hash has circular dependencies ({ \'a\' => '', \'b\' => \'c\', \'c\' => \'f\', \'d\' => \'a\', \'e\' => \'\', \'f\' => \'b\' })' do

    before(:all) do
      jobs_hash =   {  'a' => '', 'b' => 'c', 'c' => 'f', 'd' => 'a', 'e' => '', 'f' => 'b' }
      @output = OTB::JobsSequencer.call(jobs_hash: jobs_hash)
    end

    it 'returns a Failure' do
      @output.should be_an_instance_of(Dry::Monads::Result::Failure)
    end

    it 'returns an OTB::JobsSequencer::CircularReferenceError' do
      @output.failure.should be_an_instance_of(OTB::JobsSequencer::CircularReferenceError)
      @output.failure.message.should eq('Jobs can’t have circular dependencies')
    end
  end

  describe 'when a dependency is listed after the job that needs it' do
    it 'returns abcd' do
      jobs_hash = { 'd' => 'c', 'b' => 'a', 'c' => 'b', 'a' => '' }
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.should eq('abcd')
    end
  end

  describe 'when a dependency was never listed as its own job' do
    it 'returns ba' do
      jobs_hash = { 'a' => 'b' }
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.should eq('ba')
    end
  end

  describe 'when a cycle sits downstream of the first job ({ \'a\' => \'b\', \'b\' => \'c\', \'c\' => \'d\', \'d\' => \'c\' })' do
    it 'returns a CircularReferenceError failure' do
      jobs_hash = { 'a' => 'b', 'b' => 'c', 'c' => 'd', 'd' => 'c' }
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash)
      output.should be_an_instance_of(Dry::Monads::Result::Failure)
      output.failure.should be_an_instance_of(OTB::JobsSequencer::CircularReferenceError)
      output.failure.message.should eq('Jobs can’t have circular dependencies')
    end
  end

end