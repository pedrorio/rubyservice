require 'rspec'

require_relative '../../lib/jobs_sequencer'
require_relative '../../lib/jobs_parser'

describe 'On The Beach Specifications' do

  describe 'Given you’re passed an empty string (no jobs)' do

    it 'the result should be an empty sequence' do
      jobs_hash = OTB::JobsParser.call('').success
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.should eq('')
    end
  end

  describe 'Given the following job structure: \'a => \nb => c\nc => f\nd => a\ne => \nf => b\'' do
    it 'the result should be a sequence consisting of a single job a' do
      jobs_hash = OTB::JobsParser.call('a => ').success
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.should eq('a')
    end
  end

  describe 'Given the following job structure: \'a => \nb => \nc => \'' do
    it 'the result should be a sequence containing all three jobs abc' do
      jobs_hash = OTB::JobsParser.call('a => \nb => \nc => ').success
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
      output.size.should eq(3)
    end
  end

  describe 'Given the following job structure: \'a => \nb => c\nc => \'' do

    before(:all) do
      jobs_hash = OTB::JobsParser.call('a => \nb => c\nc => ').success
      @output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).success
    end

    it 'the result should be a sequence that positions c before b' do
      @output.should match(/c*b/)
    end

    it 'the result should be a sequence containing all three jobs' do
      @output.size.should eq(3)
    end
  end

  describe 'Given the following job structure: \'a => \nb => c\nc => f\nd => a\ne => b\nf => \'' do

    before(:all) do
      jobs_hash = OTB::JobsParser.call('a => \nb => c\nc => f\nd => a\ne => b\nf => ').success
      @output = OTB::JobsSequencer.call(jobs_hash:  jobs_hash).success
    end

    it 'the result should be a sequence that positions f before c' do
      @output.should match(/f*c/)
    end

    it 'the result should be a sequence that positions c before b' do
      @output.should match(/c*b/)
    end

    it 'the result should be a sequence that positions b before e' do
      @output.should match(/b*e/)
    end

    it 'the result should be a sequence that positions a before d' do
      @output.should match(/a*d/)
    end

    it 'the result should be a sequence containing all six jobs' do
      @output.size.should eq(6)
    end
  end

  describe 'Given the following job structure: \'a => \nb => \nc => c\'' do

    it 'the result should be an error stating that jobs can’t depend on themselves' do
      jobs_hash = OTB::JobsParser.call('a => \nb => \nc => c').success
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).failure
      output.should be_an_instance_of(OTB::JobsSequencer::SelfDependencyError)
    end
  end

  describe 'Given the following job structure: \'a => \nb => c\nc => f\nd => a\ne => \nf => b\'' do
    it 'the result should be an error stating that jobs can’t have circular dependencies' do
      jobs_hash = OTB::JobsParser.call('a => \nb => c\nc => f\nd => a\ne => \nf => b').success
      output = OTB::JobsSequencer.call(jobs_hash: jobs_hash).failure
      output.should be_an_instance_of(OTB::JobsSequencer::CircularReferenceError)
    end
  end

end