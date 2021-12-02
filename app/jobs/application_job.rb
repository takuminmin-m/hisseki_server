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

  # 画像を読み込む
  def read_images(filenames)
    filenames.map do |filename|
      tf.cast(tf.reduce_sum(tf.image.decode_image(tf.io.read_file(filename), channels: 4), 2, keepdims: true), tf.float32) / 255.0
    end
  end

  # image1とimage2をくっつける
  def stick_images(image1, image2)
    tf.reshape(tf.concat([image1, image2], 0), [128, 256, 1])
  end

  def create_image_list
    hissekis = Hisseki.all
    CSV.open("#{Rails.root}hisseki_list.csv") do |csv|
      hissekis.each do |hisseki|
        csv << [hisseki.image.current_path, hisseki.user.to_i]
      end
    end
  end
end
