# frozen_string_literal: true

require_relative './service'

# This module represents a namespace for classes related to the On The Beach code challenge
module OTB
  # This class represents a service that parses a string of jobs into an hash
  class JobsParser < Service
    # @attr_reader [String] string_of_jobs the string of jobs
    option :string_of_jobs

    # One job line: a word character, spaces around =>, and an optional dependency.
    PAIR_LINE = /\A(\w) => (\w)?\z/

    # the JobsParser Validation Schema
    Schema = Dry::Validation.Contract do
      params do
        required(:string_of_jobs).value(:string)
      end

      rule(:string_of_jobs) do
        next if value.empty?

        lines = value.split("\n")
        unless lines.any? && lines.all? { |line| line.match?(OTB::JobsParser::PAIR_LINE) }
          key.failure('must be empty or is in invalid format')
          next
        end

        names = lines.map { |line| line[0] }
        key.failure('a job must be listed once') if names.uniq.length != names.length
      end
    end

    # Creates a new instance of the JobsParser with the param transformed as an hash
    # @api public
    # @param string_of_jobs [String] the string of jobs
    # @return [JobsParser.new(jobs: string_of_jobs).call, Dry::Monads::Result::Failure] the status object
    # @example
    #   OTB::JobsParser.call('') #=> Success({})
    #   OTB::JobsParser.call("a => ") #=> Success({ 'a' => '' })
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
      return {} if string_of_jobs.empty?

      string_of_jobs.split("\n").each_with_object({}) do |line, jobs_hash|
        job, dependency = line.match(PAIR_LINE).captures
        jobs_hash[job] = dependency || ''
      end
    end
  end
end
