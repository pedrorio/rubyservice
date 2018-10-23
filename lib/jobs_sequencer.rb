# frozen_string_literal: true

require_relative './service'

# This module represents a namespace for classes related to the On The Beach code challenge
module OTB
  # This class represents a service that sequences jobs
  class JobsSequencer < Service
    # This class represents an error where there is a job that has itself as a dependency
    class SelfDependencyError < StandardError
      # the SelfDependencyError message
      MESSAGE = 'A list of jobs cannot have a job that has itself as a dependency'
    end

    # This class represents an error where the list of jobs has a circular dependency
    class CircularReferenceError < StandardError
      # the CircularReferenceError message
      MESSAGE = 'A list of jobs cannot have circular references'
    end

    option :jobs_hash
    permissible_errors [SelfDependencyError, CircularReferenceError]

    # the JobsSequencer Validation Schema
    Schema = Dry::Validation.Schema do
      required(:jobs_hash) { hash? }
    end

    # Parses a valid hash of jobs into a string
    # @api private
    # @return [Dry::Monads::Result::Mixin] the status class with a string_of_jobs or a permissible error
    # @example
    #   OTB::JobsSequencer.call({'a' => ''}) #=> 'a'
    #   OTB::JobsSequencer.call({'a' => 'b', 'b' => 'c'}) 'cba'
    #   OTB::JobsSequencer.call({'a' => '', 'b' => 'c'}) #=> 'acb'
    def call
      output = sequence
      Success.new(output)
    end

    private

    # Creates a new sequenced string of jobs
    # @api private
    # @return [String] the sequenced string of jobs
    def sequence
      output = jobs_hash.inject([]) do |list_of_jobs, (job, job_dependency)|
        errors?(job: job,
                job_dependency: job_dependency)

        if (job_index = list_of_jobs.find_index(job))
          list_of_jobs.insert(job_index, job_dependency)
        else
          job_dependency.empty? ? list_of_jobs << job : list_of_jobs.concat([job_dependency, job])
        end
      end

      output.uniq.join
    end

    # Verifies if the service has any permissible errors
    # @api private
    # @param [String] job key in the jobs hash
    # @param [String] job_dependency value in the jobs hash
    # @return [SelfDependencyError, CircularReferenceError, void]
    def errors?(job:, job_dependency:)
      self_dependency?(job: job,
                       job_dependency: job_dependency)

      circular_dependency?(job: job,
                           job_dependency: job_dependency,
                           selected_job_dependency: job_dependency)
    end

    # Verifies if the jobs_hash has circular references
    # @api private
    # @param [String] job the key in the hash
    # @param [String] job_dependency the value in the hash
    # @param [String] selected_job_dependency the value in the hash to compare the key value pairs
    # @return [CircularReferenceError, void]
    def circular_dependency?(job:, job_dependency:, selected_job_dependency:)
      if (parent_job_dependency = jobs_hash[selected_job_dependency])
        job_pair = [job, job_dependency]
        raise CircularReferenceError, CircularReferenceError::MESSAGE if job_pair.include?(parent_job_dependency)

        circular_dependency?(job: job, job_dependency: job_dependency, selected_job_dependency: parent_job_dependency)
      else
        false
      end
    end

    # Verifies if the jobs_hash has self dependencies
    # @api private
    # @param [String] job the key in the jobs hash
    # @param [String] job_dependency the value in the jobs hash
    # @return [SelfDependencyError, void]
    def self_dependency?(job:, job_dependency:)
      raise SelfDependencyError, SelfDependencyError::MESSAGE if job_dependency == job
    end
  end
end
