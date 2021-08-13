class CertificationHissekiJob < ApplicationJob
  queue_as :default

  def perform(hisseki_path)
    reader, writer = IO.pipe

    main_pid = fork do
      reader.close

      python_library_import
      user_classification_model = models.load_model("ml/hisseki_classification.tf")
      user_certification_model = models.load_model("ml/hisseki_certification.tf")
      puts "CertificationHissekiJob: loaded models"

      target_images = read_images [hisseki_path]
      target_images = np.array target_images
      classification_predictions = user_classification_model.predict target_images
      puts "CertificationHissekiJob: predicted user"

      target_user = User.find(np.argmax(classification_predictions[0]))
      target_user_hissekis = target_user.hissekis
      target_user_images = target_user_hissekis.map { |hisseki| hisseki.image.current_path }
      comparison_images = read_images [target_user_images[rand(target_user_images.length)]]

      paired_images = [stick_images(target_images[0], comparison_images[0])]
      paired_images = np.array paired_images

      certification_predictions = user_certification_model.predict paired_images
      puts "CertificationHissekiJob: check whether is the person"

      return_value = if np.argmax(certification_predictions[0]) == 1
        "#{target_user.id}"
      else
        "nil"
      end

      writer.write return_value
    end

    writer.close

    Process.waitpid main_pid

    user_id = eval reader.read
    return User.find(user_id) if user_id
    user_id
  end

  private

  # pythonライブラリのインポート
  def python_library_import
    pyimport :tensorflow, as: :tf
    pyfrom "tensorflow.keras", import: [:datasets, :layers, :models, :optimizers]
    pyimport :numpy, as: :np
    puts "PyCall info: imported python libraries"
  end

end
