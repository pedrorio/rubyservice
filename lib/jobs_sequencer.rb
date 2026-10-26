# frozen_string_literal: true

require_relative './service'

# This module represents a namespace for classes related to the On The Beach code challenge
module OTB
  # This class represents a service that sequences jobs
  class JobsSequencer < Service
    # This class represents an error where there is a job that has itself as a dependency
    class SelfDependencyError < StandardError
      # the SelfDependencyError message
      MESSAGE = 'Jobs can’t depend on themselves'
    end

    # This class represents an error where the list of jobs has a circular dependency
    class CircularReferenceError < StandardError
      # the CircularReferenceError message
      MESSAGE = 'Jobs can’t have circular dependencies'
    end

    option :jobs_hash
    permissible_errors [SelfDependencyError, CircularReferenceError]

    # the JobsSequencer Validation Schema
    Schema = Dry::Validation.Contract do
      params do
        required(:jobs_hash).value(:hash)
      end
    end

    # Parses a valid hash of jobs into a string
    # @api private
    # @return [Dry::Monads::Result::Mixin] the status class with a string_of_jobs or a permissible error
    # @example
    #   OTB::JobsSequencer.call(jobs_hash: { 'a' => '' }).success #=> "a"
    #   OTB::JobsSequencer.call(jobs_hash: { 'a' => 'b', 'b' => 'c' }).success #=> "cba"
    #   OTB::JobsSequencer.call(jobs_hash: { 'a' => '', 'b' => 'c', 'c' => '' }).success #=> "acb"
    def call
      Success.new(sequence)
    end

    private

    # Orders jobs so each dependency comes first.
    # @api private
    # @return [String] the sequenced string of jobs
    def sequence
      reject_self_dependencies
      ordered = topological_order
      raise CircularReferenceError, CircularReferenceError::MESSAGE if ordered.nil?

      ordered.join
    end

    # @api private
    # @return [void]
    def reject_self_dependencies
      jobs_hash.each do |job, dependency|
        raise SelfDependencyError, SelfDependencyError::MESSAGE if dependency == job
      end
    end

    # Hash keys in insertion order, then dependencies that were never listed as jobs.
    # @api private
    # @return [Array<String>]
    def node_names
      seen = {}
      ordered = []
      jobs_hash.each_key { |job| append_node(ordered, seen, job) }
      jobs_hash.each_value do |dependency|
        next if dependency.empty?

        append_node(ordered, seen, dependency)
      end
      ordered
    end

    # @api private
    # @param ordered [Array]
    # @param seen [Hash]
    # @param name [String]
    # @return [void]
    def append_node(ordered, seen, name)
      return if seen[name]

      seen[name] = true
      ordered << name
    end

    # Stable FIFO order. Returns nil when a cycle leaves some jobs unscheduled.
    # @api private
    # @return [Array, nil]
    def topological_order
      ordered_nodes = node_names
      indegree = ordered_nodes.to_h { |name| [name, 0] }
      dependents = dependency_edges(indegree)
      queue = ordered_nodes.select { |name| indegree[name].zero? }
      result = drain(queue, indegree, dependents)
      return nil if result.size < ordered_nodes.size

      result
    end

    # @api private
    # @param indegree [Hash]
    # @return [Hash]
    def dependency_edges(indegree)
      jobs_hash.each_with_object({}) do |(job, dependency), dependents|
        next if dependency.empty?

        (dependents[dependency] ||= []) << job
        indegree[job] += 1
      end
    end

    # @api private
    # @param queue [Array]
    # @param indegree [Hash]
    # @param dependents [Hash]
    # @return [Array]
    def drain(queue, indegree, dependents)
      result = []
      until queue.empty?
        name = queue.shift
        result << name
        release(dependents[name], indegree, queue)
      end
      result
    end

    # @api private
    # @param names [Array, nil]
    # @param indegree [Hash]
    # @param queue [Array]
    # @return [void]
    def release(names, indegree, queue)
      (names || []).each do |dependent|
        indegree[dependent] -= 1
        queue << dependent if indegree[dependent].zero?
      end
    end
  end
end
