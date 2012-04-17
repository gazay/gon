# rabl_spec_rb
require 'gon'

describe Gon do

  before(:each) do
    Gon::Request.env = {}
  end

  require 'jbuilder'
  require 'gon/jbuilder'
  require 'rabl'
  require 'gon/rabl'

  describe '.get_template_path' do
    context 'template is specified' do

      it 'add the extension if not included in the template name' do
        Gon::Base.send(:get_template_path, { :template => 'spec/test_data/sample'}, 'jbuilder').should eql('spec/test_data/sample.jbuilder')
      end

      it 'return the specified template' do
        Gon::Base.send(:get_template_path, { :template => 'spec/test_data/sample.jbuilder'}, 'jbuilder').should eql('spec/test_data/sample.jbuilder')
      end

    end

    context 'template is not specified' do

      before do
        Gon.clear
        controller.instance_variable_set('@objects', objects)
        controller.action_name = 'show'
      end

      let(:controller) { ActionController::Base.new }
      let(:objects) { [1,2] }

      context 'the action doesn as a template at a different format' do
        it 'return the same template as the action with rabl extension' do
          Gon::Base.send(:get_template_path, {:controller => controller}, 'jbuilder').should eql('app/views/action_controller/base/show.json.jbuilder')
        end
      end

    end
  end

  def request
    @request ||= double 'request', :env => {}
  end

end
