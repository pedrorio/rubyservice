# frozen_string_literal: true

require 'dry-initializer'
require 'dry-validation'
require 'dry/monads/result'
require 'dry/core'

# This class represents a service that validate inputs, standardises outputs and handles permissible errors
# @abstract
class Service
  extend Dry::Initializer
  include Dry::Monads::Result::Mixin
  extend Dry::Core::ClassAttributes

  defines :permissible_errors
  permissible_errors []

  # Validates the service inputs and processes the service errors
  # @abstract
  # @api private
  # @param args
  # @return [Dry::Monads::Result::Failure, Service.new(args).call]
  def self.call(args)
    validation = self::Schema.call(args)
    return Failure.new(validation.errors) unless validation.success?

    new(args).call
  rescue StandardError => error
    handle_error(error)
  end

  # Processes errors into non permissible errors or failures with permissible errors
  # @api private
  # @raise StandardError if the error is not permissible
  # @param error [StandardError]
  # @return [Dry::Monads::Result::Failure, StandardError]
  def self.handle_error(error)
    raise error unless permissible_errors.any? { |type| error.is_a?(type) }

    Failure.new(error)
  end

  private_class_method :handle_error
end
