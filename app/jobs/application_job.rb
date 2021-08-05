class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  require 'pycall/import'
  include PyCall::Import

  class Array
    def delete_dir
      self.delete_if { |filename| File::ftype(filename) == "directory" }
    end

    def pickup!(begin_index, quantity)
      picked = self.slice(begin_index, quantity)
      self.slice!(begin_index, quantity)
      picked
    end
  end

  private

    def read_images(filenames)
      filenames.map do |filename|
        tf.image.decode_image(tf.io.read_file(filename), channels: 1)
      end
    end
end
