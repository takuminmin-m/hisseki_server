class LearnHissekiJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # pythonライブラリのインポート
    include PyCall
    pyimport :tensorflow, as: :tf
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np
    pyimport "matplotlib.pyplot", as: :plt

    #ファイルを収集
    datas = Hisseki.all
    learn_hissekis = datas.map { |e| e.image.current_path }
    learn_labels = datas.map { |e| e.user_id }

    p learn_hissekis
    p learn_labels

  end
end
