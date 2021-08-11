class LearnHissekiJob < ApplicationJob
  queue_as :default

  def perform
    pyimport :tensorflow, as: :tf
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np
    pyimport "matplotlib.pyplot", as: :plt

    hisseki_datas = set_datas

    make_classification_model(hisseki_datas).save("ml/hisseki_classification.tf")
    puts "LearnHissekiJob: saved classification model"
  end

  private

  # 画像ファイルをすべて読み込む
  def set_datas
    datas = Hisseki.all
    hisseki_image_paths = datas.map { |hisseki| hisseki.image.current_path }
    hisseki_images = read_images(hisseki_image_paths)
    hisseki_images.map! { |image| tf.cast(image, tf.float32) / 255.0 }
    hissekis = datas.map.with_index do |hisseki, i|
      {
        label: hisseki.user_id,
        image: hisseki_images[i]
      }
    end
    puts "LearnHissekiJob: loaded hissekis"
    hissekis.shuffle!
  end

  # ユーザー分類用モデルを作る
  def make_classification_model(learn_datas)
    learn_images = np.array learn_datas.map { |hisseki| hisseki[:image] }
    learn_labels = np.array learn_datas.map { |hisseki| hisseki[:label] }

    member_num = learn_datas.map { |hisseki| hisseki[:label] }.uniq.length + 1

    puts "LearnHissekiJob: start to make classification model"
    model = models.Sequential.new([
      layers.Conv2D.new(64, [5, 5], activation: :relu, input_shape: [128, 128, 1]),
      layers.MaxPooling2D.new([4, 4]),
      layers.Conv2D.new(64, [5, 5], activation: :relu),
      layers.MaxPooling2D.new([4, 4]),
      layers.Conv2D.new(32, [5, 5], activation: :relu),
      layers.Flatten.new,
      layers.Dense.new(128, activation: :relu),
      layers.Dense.new(member_num, activation: :softmax)
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

    puts "LearnHissekiJob: finish making classification model"
    model
  end
end
