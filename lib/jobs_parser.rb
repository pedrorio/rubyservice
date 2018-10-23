# frozen_string_literal: true

require_relative './service'

# This module represents a namespace for classes related to the On The Beach code challenge
module OTB
  # This class represents a service that parses a string of jobs into an hash
  class JobsParser < Service
    # @attr_reader [String] string_of_jobs the string of jobs
    option :string_of_jobs

    # the JobsParser Validation Schema
    Schema = Dry::Validation.Schema do
      required(:string_of_jobs) { str? & empty? | format?(/(\w) => (\w|)/) }
    end

    # Creates a new instance of the JobsParser with the param transformed as an hash
    # @api public
    # @param string_of_jobs [String] the string of jobs
    # @return [JobsParser.new(jobs: string_of_jobs).call, Dry::Monads::Result::Failure] the status object
    # @example
    #   OTB::JobsParser.call('')  #=> Success('')
    #   OTB::JobsParser.call('\'a\' => \'\'') #=> Success({ 'a' => ''})
    #   OTB::JobsParser.call('Hello World') #=> Failure({:string_of_jobs=>["must be empty or is in invalid format"]})
    def self.call(string_of_jobs)
      args = { string_of_jobs: string_of_jobs }
      super(args)
    end

    # Parses a valid string of jobs into an hash
    # @api private
    # @return [Dry::Monads::Result::Mixin] the status class with the jobs hash
    def call
      output = parse
      Success.new(output)
    end

    private

    # Parses a string of jobs into an hash
    # @api private
    # @return [Hash] the jobs hash
    def parse
      string_of_jobs.scan(/(\w) => (\w|)/).each_with_object({}) do |pair, jobs_hash|
        jobs_hash[pair.first] = pair.last
      end
    end
  end
end
