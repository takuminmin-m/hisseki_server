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

  def python_library_import
    pyimport :tensorflow, as: :tf
    pyfrom :tensorflow, import: :keras
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np
    pyimport :sys

    sys.path.append(Rails.root.join("ml/python_script/").to_s)
    pyfrom "functions", import: :load_and_preprocess_image

    puts "PyCall info: imported python libraries"
  end

  # 画像を読み込む
  def read_images(filenames)
    # filenames.map do |filename|
    #   tf.cast(tf.reduce_sum(tf.image.decode_image(tf.io.read_file(filename), channels: 4), 2, keepdims: true), tf.float32) / 255.0
    # end

    filenames.map do |filename|
      load_and_preprocess_image(filename)
    end
  end

  def generate_image_csv
    all_hissekis = Hisseki.all

    CSV.open("ml/hisseki_list.csv", "w") do |list|
      all_hissekis.each do |hisseki|
        list << [hisseki.user_id, hisseki.image.current_path]
      end
    end
  end
end
