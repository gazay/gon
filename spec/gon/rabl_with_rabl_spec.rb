require 'spec_helper'

describe Gon do
  
  before(:all) do
    ensure_rabl_is_loaded
  end

  before(:each) do
    Gon::Request.env = {}
  end

  describe '.rabl' do

    before :each do
      Gon.clear
      controller.instance_variable_set('@objects', objects)
    end

    let(:controller) { ActionController::Base.new }
    let(:objects) { [1,2] }

    context 'render template with deprecation' do
      it 'still works' do
        Gon.rabl 'spec/test_data/sample.rabl', :controller => controller
        Gon.objects.length.should == 2
      end
    end

    context 'option locals' do
      it 'works without locals object properly' do
        Gon.rabl(
          :template =>'spec/test_data/sample.rabl',
          :controller => controller
        )
        Gon.objects.map { |it| it['object']['inspect'] }.should == ['1', '2']
      end

      it 'works with different locals object' do
        Gon.rabl(
          :template =>'spec/test_data/sample.rabl',
          :controller => controller,
          :locals => { :objects => [3, 4] }
        )
        Gon.objects.map { |it| it['object']['inspect'] }.should == ['3', '4']
      end
    end

    it 'works if rabl is included' do
      Gon.rabl :template =>'spec/test_data/sample.rabl', :controller => controller
      Gon.objects.length.should == 2
    end

    it 'works with ActionView::Helpers' do
      Gon.rabl :template =>'spec/test_data/sample_with_helpers.rabl', :controller => controller
      Gon.objects.first['object']['time_ago'].should == 'about 6 hours'
    end

    it 'raise exception if rabl is not included' do
      Gon.send :remove_const, 'Rabl'
      expect { Gon.rabl :template =>'spec/test_data/sample.rabl', :controller => controller}.to raise_error
      load 'rabl.rb'
      load 'gon/rabl.rb'
    end

    context '.get_template_path' do
      context 'template is specified' do

        it 'add the extension if not included in the template name' do
          Gon::Base.send(:get_template_path, { :template => 'spec/test_data/sample'}, 'rabl').should eql('spec/test_data/sample.rabl')
        end

        it 'return the specified template' do
          Gon::Base.send(:get_template_path, { :template => 'spec/test_data/sample.rabl'}, 'rabl').should eql('spec/test_data/sample.rabl')
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
            Gon::Base.send(:get_template_path, {:controller => controller}, 'rabl').should eql('app/views/action_controller/base/show.json.rabl')
          end
        end

      end
    end

  end

  def request
    @request ||= double 'request', :env => {}
  end

end
