require 'spec_helper'

def get_spreadsheet(name = 'staging')
  Roo::Excelx.new("#{Rails.root}/spec/support/#{name}.xlsx")
end

describe Importer do

  let(:importer) { Importer.new }

  context '#import' do
    subject { lambda { importer.import} }

    before :each do
      Time.zone.stub(:current_week_number).and_return(24)

      importer.stub(:get_comments_from_spreadsheet)
        .and_return([[3, 31, "Comment on Yong Gu 6/16"],
          [3, 21, "kick-off"], [3, 26, "delivery"],
          [3, 26, "kick-off"], [3, 28, "delivery"]])
    end

    context "when succeeded" do
      before do
        importer.stub(:spreadsheet).and_return(get_spreadsheet)
      end

      it { should change(Import, :count).by(1) }
      it "creates a import with success is true" do
        importer.import
        Import.first.success.should be_true
      end

      it { should change(User, :count).by(2) }
      it "creates two users with name 'Yong Gu' and 'Jeff Baier'" do
        importer.import
        User.all.map(&:name).sort.should =~ ["Jeff Baier", "Yong Gu"]
      end

      it { should change(RawItem, :count).by(2) }
      it { should change(Project, :count).by(2) }

      it "creates two projects with name 'Dashboard' and 'Education'" do
        importer.import
        Project.all.map(&:name).should =~ ["Dashboard", "Education"]
      end

      it { should change(WeekHour, :count).by(8) } # calculated by current week number

      it "creates 8 week hours with hours 10.0, 20.0, 30.0, 40.0, 40.0, 30.0, 20.0 and 10.0" do
        importer.import
        WeekHour.order("user_id asc, week asc").all.map(&:hours).should == ["10.0", "20.0", "30.0", "40.0", "40.0", "30.0", "20.0", "10.0"]
      end

      it "should attach comments to weekhour" do
        importer.import
        Project.find_by_name("Dashboard").week_hours.first.comment.text.should == "Comment on Yong Gu 6/16"
      end

      it "should update project kickoff date" do
        importer.import
        Project.find_by_name("Dashboard").date_kickoff.should == Time.zone.end_of_week(14, 2013).to_date
      end

      it "should update project delivered date" do
        importer.import
        Project.find_by_name("Dashboard").date_delivered.should == Time.zone.end_of_week(19, 2013).to_date
      end

      it "should update project target date" do
        importer.import
        Project.find_by_name("Dashboard").date_target.should == Time.zone.end_of_week(19, 2013).to_date
      end

      it "should import data for 2014" do
        Time.zone.stub(:now).and_return(DateTime.parse("2014-01-04"))
        Time.zone.unstub(:current_week_number)

        importer.stub(:spreadsheet).
          and_return(get_spreadsheet("multi-year-spreadsheet"))
        importer.import

        WeekHour.all.map(&:hours) =~ ["6.0", "7.0", "8.0", "9.0"]
      end
    end

    context "when deleting spreadsheet data" do
      it "deletes the record from the database" do
        Time.zone.stub(:current_week_number).and_return(6)
        importer.stub(:spreadsheet).and_return(get_spreadsheet('two-weekhours'))
        importer.import

        WeekHour.count.should == 2

        importer.stub(:spreadsheet).and_return(get_spreadsheet('one-weekhour'))
        importer.import

        WeekHour.count.should == 1
      end
    end

    context "when failed" do
      before :each do
        importer.stub(:spreadsheet).and_raise("Can not instantiate google spreadsheet")
      end

      it { should_not change(User, :count) }
      it { should_not change(RawItem, :count) }
      it { should_not change(Project, :count) }
      it { should_not change(WeekHour, :count) }

      it "creates an Import with success is false" do
        importer.import
        Import.first.success.should be_false
      end
    end

  end
end
