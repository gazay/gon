require 'spec_helper'

describe Gon do
  
  before(:all) do
    ensure_rabl_rails_is_loaded
  end

  before(:each) do
    Gon::Request.env = {}
  end

  describe '.rabl with rabl-rails gem' do

    before :each do
      Gon.clear
      controller.instance_variable_set('@objects', objects)
      controller.request = ActionDispatch::TestRequest.new
    end
  
    let(:controller) { ActionController::Base.new }
    let(:objects) { [1,2] }
  
    context 'render template with deprecation' do
      it 'still works' do
        Gon.rabl 'spec/test_data/sample_rabl_rails.rabl', :controller => controller
        Gon.objects.length.should == 2
      end
    end
  
    context 'option locals' do
      it 'works without locals object properly' do
        Gon.rabl(
          :template =>'spec/test_data/sample_rabl_rails.rabl',
          :controller => controller
        )
        Gon.objects.map { |it| it['inspect'] }.should == ['1', '2']
      end
      
      it 'works with different locals object' do
        Gon.rabl(
          :template =>'spec/test_data/sample_rabl_rails.rabl',
          :controller => controller,
          :locals => { :objects => [3, 4] }
        )
        Gon.objects.map { |it| it['inspect'] }.should == ['3', '4']
      end
    end
  
    it 'works if rabl-rails is included' do
      Gon.rabl :template =>'spec/test_data/sample_rabl_rails.rabl', :controller => controller
      Gon.objects.length.should == 2
    end
  
    it 'works with ActionView::Helpers' do
      Gon.rabl :template =>'spec/test_data/sample_with_helpers_rabl_rails.rabl', :controller => controller
      Gon.objects.first['time_ago'].should == 'about 6 hours'
    end
  
    it 'raise exception if rabl or rabl-rails is not included' do
      Object.send :remove_const, :RablRails # ensure_rabl_rails_is_loaded method already removed Rabl
      expect { Gon.rabl :template =>'spec/test_data/sample.rabl', :controller => controller}.to raise_error
      ensure_rabl_rails_is_loaded # load up rabl-rails again, we're not done testing
    end

  end

end
