require 'spec_helper'

describe Skill do

  context ".matching" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project, name: "P A") }
    let(:skill) { FactoryGirl.create(:skill, name: "Rails") }

    before do
      FactoryGirl.create(:required_skill, project: project, skill: skill)
      FactoryGirl.create(:experience, skill: skill, user: user)
    end

    it "should find projects that need user's skills" do
      Skill.matching(user, Project.all).should == [["P A", 1]]
    end

    it "should find users that match project's skill need" do
      Skill.matching(project, User.all).should == [["Gary Flandro", 1]]
    end
  end

end
