class LearnHissekiJob < ApplicationJob
  queue_as :default
  require 'pycall/import'
  include PyCall::Import

  def perform
    pyimport :tensorflow, as: :tf
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np
    pyimport "matplotlib.pyplot", as: :plt

    #ファイルを収集
    datas = Hisseki.all
    hisseki_image_paths = datas.map { |hisseki| hisseki.image.current_path }
    hisseki_images = read_images(hisseki_image_paths)
    hisseki_images.map! { |image| tf.cast(image, tf.float32) / 255.0 }
    hissekis = datas.map_with_index do |hisseki, i|
      {
        label: hisseki.user_id,
        image: hisseki_images[i]
      }
    end
    hissekis.shuffle!
    puts "LearnHissekiJob: loaded hissekis"

    learn_images = np.array hissekis.map { |hisseki| hisseki.image }
    learn_labels = np.array hissekis.map { |hisseki| hisseki.label }

    model = models.Sequential.new([
      layers.Conv2D.new(64, [5, 5], activation: :relu, input_shape: [118, 128, 1]),
      layers.MaxPooling2D.new([4, 4]),
      layers.Conv2D.new(64, [5, 5], activation: :relu),
      layers.MaxPooling2D.new([4, 4]),
      layers.Conv2D.new(32, [5, 5], activation: :relu),
      layers.Flatten.new,
      layers.Dense.new(128, activation: :relu),
      layers.Dense.new(members.length, activation: :softmax)
    ])

    adam = tf.keras.optimizers.Adam.new(
      learning_rate: 0.001,
    )

    model.compile(
      optimizer: adam,
      loss: :sparse_categorical_crossentropy,
      metrics: [:accuracy]
    )
    model.fit learn_images, learn_labels, epochs: 20

    # model.save("models/tf/#{t_str}")
  end
end
