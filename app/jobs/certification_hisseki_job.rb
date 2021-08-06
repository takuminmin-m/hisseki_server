class CertificationHissekiJob < ApplicationJob
  queue_as :default
  require 'pycall/import'
  include PyCall::Import

  def perform(hisseki_path)
    users = np.array ["takumi", "tanbo"]

    user_classification_model = models.load_model("ml/hisseki_classification.tf")
    # user_certification_model = models.load_model("models/tf_pair/2021724202849")

    target_images = read_images [hisseki_path]
    target_images = np.array target_images
    classification_predictions = user_classification_model.predict target_images

    return target_user_id = np.argmax(classification_predictions[0])

    target_user = users[np.argmax(classification_predictions[0])]
    comparison_images = read_images ["image/#{target_user}/base10.png"]

    paired_images = [make_pair(target_images[0], comparison_images[0])]
    paired_images = np.array paired_images

    certification_predictions = user_certification_model.predict paired_images
    puts certification_predictions
  end
end
