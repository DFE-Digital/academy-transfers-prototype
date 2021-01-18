require "rails_helper"

RSpec.describe Project, type: :model do
  let(:user) { create :user }
  let(:academy) { build :academy }
  let(:incoming_trust) { build :trust }
  let(:outgoing_trust) { build :trust }
  let(:project_status) { Project::STATUS[:in_progress] }
  let(:project) do
    described_class.new(
      project_initiator_uid: user.uid,
      project_initiator_full_name: user.username,
      project_status: project_status,
      academy_ids: [academy.id],
      outgoing_trust_id: outgoing_trust.id,
      incoming_trust_id: incoming_trust.id,
    )
  end

  describe "#save" do
    let(:response) { project.save }
    let(:response_body) { { foo: :bar }.to_json }

    before do
      mock_project_save(project, response_body)
    end

    it "posts the api payload to the API" do
      expect(response.status).to eq(200)
      expect(response.body).to eq(response_body)
    end
  end

  describe "#api_payload" do
    let(:api_payload) { project.api_payload }
    it "contains the user data" do
      expect(api_payload["projectInitiatorUid"]).to eq(user.uid)
      expect(api_payload["projectInitiatorFullName"])
    end

    it "contains the product status" do
      expect(api_payload["projectStatus"]).to eq(project_status)
    end

    it "contains the project_academies" do
      expect(api_payload.dig("projectAcademies", 0, "academyId")).to eq(academy.id)
    end

    it "contains the incoming trust id" do
      expect(api_payload.dig("projectTrusts", 0, "trustId")).to eq(incoming_trust.id)
    end
  end

  describe "#project_academies" do
    let(:project_academy) { project.project_academies.first }

    it "contains academy id" do
      expect(project_academy[:academy_id]).to eq(academy.id)
    end

    it "contain outgoing trust id" do
      expect(project_academy.dig(:trusts, 0, :trust_id)).to eq(outgoing_trust.id)
    end
  end
end
