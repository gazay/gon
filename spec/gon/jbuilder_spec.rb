# rabl_spec_rb
require 'gon'

describe Gon do

  before(:each) do
    Gon::Request.env = {}
  end

  require 'jbuilder'
  require 'gon/jbuilder'

  describe '.jbuilder' do
    context 'render jbuilder templates' do

      before do
        Gon.clear
        controller.instance_variable_set('@objects', objects)
      end

      let(:controller) { ActionController::Base.new }
      let(:objects) { [1,2] }

      it 'render json from jbuilder template' do
        Gon.jbuilder 'spec/test_data/sample.json.jbuilder', :controller => controller
        Gon.objects.length.should == 2
      end

      it 'render json from jbuilder template with helpers' do
        Gon.jbuilder 'spec/test_data/sample_with_helpers.json.jbuilder', :controller => controller
        Gon.date.should == 'about 6 hours'
      end

      it 'render json from jbuilder template with a partial' do
        controller.view_paths << 'spec/test_data'
        Gon.jbuilder 'spec/test_data/sample_with_partial.json.jbuilder', :controller => controller
        Gon.objects.length.should == 2
      end

    end

    it 'should raise error if you use gon.jbuilder without requiring jbuilder gem' do
      Gon.send(:remove_const, :Jbuilder)

      expect { Gon.jbuilder 'some_path' }.to raise_error
      load 'jbuilder.rb'
      load 'gon/jbuilder.rb'
    end

  end


  def request
    @request ||= double 'request', :env => {}
  end

end
