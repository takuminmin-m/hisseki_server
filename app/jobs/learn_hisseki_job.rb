class LearnHissekiJob < ApplicationJob
  queue_as :default

  def perform
    python_library_import
    hisseki_datas = set_datas

    make_classification_model(hisseki_datas).save("ml/hisseki_classification.tf")
    puts "LearnHissekiJob: saved classification model"

    make_certification_model(hisseki_datas).save("ml/hisseki_certification.tf")
    puts "LearnHissekiJob: saved certification model"

    puts "LearnHissekiJob: finished job"
  end

  private

  # pythonライブラリのインポート
  def python_library_import
    pyimport :tensorflow, as: :tf
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np

    puts "PyCall info: imported python libraries"
  end

  # 画像ファイルをすべて読み込む
  # return_value = [
  #   {
  #     label: user_id,
  #     image: user_image
  #   }
  # ]
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

  # ユーザーごとにファイルを分ける
  # datas: Hash, key: Symbol
  def separate(datas, key)
    categories = datas.map { |data| data[key] }.uniq.sort
    separated_datas = categories.map do |category|
      datas.select { |data| data[key] = category }
    end
    [separated_datas, categories]
  end

  # 画像ファイルをペアにして返す
  # return_value = [
  #   [image1, image2, image3, .....], # ２つの画像をくっつけた画像
  #   [label1, label2, label3, .....]  # 画像に対応するラベル 1:書いたユーザーが一致 0:一致しない
  # ]
  def make_pairs(datas)
    members_datas, = separate(datas, :label)
    members_images = members_datas.map do |member_datas|
      member_datas.map { |data| data[:image] }
    end
    matched_pairs = [] # 書いたユーザーが一致
    not_matched_pairs = [] # 書いたユーザーが一致しない
    # [
    #   [image1, image2],
    #   [image3, image4],.....
    # ]

    # 総当りで画像を組み合わせる
    # 親ユーザー
    members_images.each_with_index do |images, member_index|
      images.each do |image|
        members_images.each_with_index do |sub_images, sub_member_index|
          if member_index == sub_member_index
            matched_pairs += sub_images.map { |sub_image| [image, sub_image] }
          else
            not_matched_pairs += sub_images.map { |sub_image| [image, sub_image] }
          end
        end
      end
    end

    # TODO: matched_pairsの中の、同じ画像のペアを取り除く
    [matched_pairs, not_matched_pairs]
  end

  # # image1とimage2をくっつける
  # def stick_images(image1, image2)
  #   tf.reshape(tf.concat([image1, image2], 0), [128, 256, 1])
  # end

  # ユーザー分類用モデルを作る
  def make_classification_model(learn_datas)
    learn_images = np.array learn_datas.map { |data| data[:image] }
    learn_labels = np.array learn_datas.map { |data| data[:label] }

    member_num = User.last.id + 1

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

    model.compile(
      optimizer: adam(learning_rate: 0.001),
      loss: :sparse_categorical_crossentropy,
      metrics: [:accuracy]
    )

    model.fit learn_images, learn_labels, epochs: 20, verbose: 0

    puts "LearnHissekiJob: finish making classification model"
    model
  end

  def adam(params)
    tf.keras.optimizers.Adam.new(**params)
  end

  # 認証用モデルを作る
  def make_certification_model(learn_datas)
    matched_pairs, not_matched_pairs = make_pairs(learn_datas)

    matched_pairs.map! { |pair| stick_images pair[0], pair[1] }.shuffle!
    not_matched_pairs.map! { |pair| stick_images pair[0], pair[1] }.shuffle!

    train_datas = []
    [not_matched_pairs, matched_pairs].each_with_index do |pairs, i|
      train_datas += pairs.map do |image|
        {
          label: i,
          image: image
        }
      end
    end

    train_images = np.array train_datas.map { |data| data[:image] }
    train_labels = np.array train_datas.map { |data| data[:label] }

    puts "LearnHissekiJob: start to make certification model"
    model = models.Sequential.new([
      layers.Conv2D.new(64, [5, 5], activation: :relu, input_shape: [128, 256, 1]),
      layers.MaxPooling2D.new([4, 4]),
      layers.Conv2D.new(64, [5, 5], activation: :relu),
      layers.MaxPooling2D.new([4, 4]),
      layers.Conv2D.new(32, [5, 5], activation: :relu),
      layers.Flatten.new,
      layers.Dense.new(128, activation: :relu),
      layers.Dense.new(2, activation: :softmax)
    ])

    model.compile(
      optimizer: adam(learning_rate: 0.001),
      loss: :sparse_categorical_crossentropy,
      metrics: [:accuracy]
    )

    model.fit train_images, train_labels, epochs: 20, verbose: 0
    puts "LearnHissekiJob: finish making certification model"

    model
  end
end
