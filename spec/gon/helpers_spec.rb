# frozen_string_literal: true

describe 'Gon Helpers' do
  def wrap_script(content, cdata=true)
    script = +"<script>"
    script << "\n//<![CDATA[\n" if cdata
    script << content
    script << "\n//]]>\n" if cdata
    script << '</script>'
  end
  let(:request) { RequestStore.store[:gon] }
  let(:view) do
    v = ActionView::Base.new(nil, {}, nil)
    v.request = request
    v
  end

  before do
    RequestStore.store[:gon] = Gon::Request.new({})
    Gon.clear
    Gon::Global.clear
  end

  describe '#include_gon' do
    context 'basic functionality' do
      it 'outputs correct js with an integer' do
        Gon.int = 1
        expect(view.include_gon).to eq(wrap_script(
                                  'window.gon={};' +
                                  'gon.int=1;'))
      end

      it 'outputs correct js with a string' do
        Gon.str = %q(a'b"c)
        expect(view.include_gon).to eq(wrap_script(
                                  'window.gon={};' +
                                  %q(gon.str="a'b\"c";))
        )
      end

      it 'outputs correct js with a script string' do
        Gon.str = %q(</script><script>alert('!')</script>)
        escaped_str = "\\u003c/script\\u003e\\u003cscript\\u003ealert('!')\\u003c/script\\u003e"
        expect(view.include_gon).to eq(wrap_script(
                                  'window.gon={};' +
                                  %Q(gon.str="#{escaped_str}";))
        )
      end
    end

    context 'formatting options' do
      it 'outputs correct js with an integer and type' do
        Gon.int = 1
        expect(view.include_gon(type: true)).to eq('<script type="text/javascript">' +
                                      "\n//<![CDATA[\n" +
                                      'window.gon={};' +
                                      'gon.int=1;' +
                                      "\n//]]>\n" +
                                    '</script>')
      end

      it 'outputs correct js with an integer, camel-case and namespace' do
        Gon.int_cased = 1
        expect(view.include_gon(camel_case: true, namespace: 'camel_cased')).to eq(
                                    wrap_script('window.camel_cased={};' +
                                      'camel_cased.intCased=1;')
        )
      end

      it 'outputs correct js with camel_depth = :recursive' do
        Gon.test_hash = { test_depth_one: { test_depth_two: 1 } }
        expect(view.include_gon(camel_case: true, camel_depth: :recursive)).to eq(
                                    wrap_script('window.gon={};' +
                                      'gon.testHash={"testDepthOne":{"testDepthTwo":1}};')
        )
      end

      it 'outputs correct js with camel_depth = 2' do
        Gon.test_hash = { test_depth_one: { test_depth_two: 1 } }
        expect(view.include_gon(camel_case: true, camel_depth: 2)).to eq(
                                    wrap_script('window.gon={};' +
                                      'gon.testHash={"testDepthOne":{"test_depth_two":1}};')
        )
      end

      it 'outputs correct js for an array with camel_depth = :recursive' do
        Gon.test_hash = { test_depth_one: [{ test_depth_two: 1 }, { test_depth_two: 2 }] }
        expect(view.include_gon(camel_case: true, camel_depth: :recursive)).to eq( \
                                    wrap_script('window.gon={};' +
                                      'gon.testHash={"testDepthOne":[{"testDepthTwo":1},{"testDepthTwo":2}]};')
        )
      end

      it 'outputs correct key with camel_case option set alternately ' do
        Gon.test_hash = 1
        view.include_gon(camel_case: true)

        expect(view.include_gon(camel_case: false)).to eq(
                                   wrap_script('window.gon={};' +
                                     'gon.test_hash=1;')
        )
      end
    end

    context 'output options' do
      it 'outputs correct js with an integer and without tag' do
        Gon.int = 1
        expect(view.include_gon(need_tag: false)).to eq( \
                                    'window.gon={};' +
                                    'gon.int=1;'
        )
      end

      it 'outputs correct js without variables, without tag and gon init if before there was data' do
        Gon::Request.instance_variable_set(:@env, { 'gon' => { :a => 1 } })
        expect(view.include_gon(need_tag: false, init: true)).to eq( \
                                    'window.gon={};'
        )
      end

      it 'outputs correct js without variables, without tag and gon init' do
        expect(view.include_gon(need_tag: false, init: true)).to eq( \
                                    'window.gon={};'
        )
      end

      it 'outputs correct js without variables, without tag, gon init and an integer' do
        Gon.int = 1
        expect(view.include_gon(need_tag: false, init: true)).to eq( \
                                    'window.gon={};' +
                                    'gon.int=1;'
        )
      end

      it 'outputs correct js without cdata, without type, gon init and an integer' do
        Gon.int = 1
        expect(view.include_gon(cdata: false, type: false)).to eq(
                                    wrap_script(
                                      "\n" +
                                      'window.gon={};' +
                                      'gon.int=1;' +
                                      "\n", false)
        )
      end

      it 'outputs correct js with type text/javascript' do
        expect(view.include_gon(need_type: true, init: true)).to eq(wrap_script('window.gon={};'))
      end

      it 'outputs correct js with namespace check' do
        expect(view.include_gon(namespace_check: true)).to eq(wrap_script('window.gon=window.gon||{};'))
      end

      it 'outputs correct js without namespace check' do
        expect(view.include_gon(namespace_check: false)).to eq(wrap_script('window.gon={};'))
      end
    end

    context 'global variables' do
      it 'outputs correct js with a global integer' do
        Gon.global.int = 1
        expect(view.include_gon).to eq("<script>" +
                                      "\n//<![CDATA[\n" +
                                      "window.gon={};" +
                                      "gon.global={\"int\":1};" +
                                      "\n//]]>\n" +
                                    "</script>")
      end

      it 'outputs correct js with both global and local integers' do
        Gon.int = 1
        Gon.global.int = 1
        expect(view.include_gon).to eq("<script>" +
                                      "\n//<![CDATA[\n" +
                                      "window.gon={};" +
                                      "gon.global={\"int\":1};" +
                                      "gon.int=1;" +
                                      "\n//]]>\n" +
                                    "</script>")
      end

      it 'outputs correct js with a global string' do
        Gon.global.str = %q(a'b"c)
        expect(view.include_gon).to eq("<script>" +
                                      "\n//<![CDATA[\n" +
                                      "window.gon={};" +
                                      "gon.global={\"str\":\"a'b\\\"c\"};" +
                                      "\n//]]>\n" +
                                    "</script>")
      end

      it 'outputs correct js with a global script string' do
        Gon.global.str = %q(</script><script>alert('!')</script>)
        escaped_str = "\\u003c/script\\u003e\\u003cscript\\u003ealert('!')\\u003c/script\\u003e"
        expect(view.include_gon).to eq("<script>" +
                                      "\n//<![CDATA[\n" +
                                      "window.gon={};" +
                                      "gon.global={\"str\":\"#{escaped_str}\"};" +
                                      "\n//]]>\n" +
                                    "</script>")
      end

      it 'outputs correct js with a unicode line separator in global' do
        Gon.global.str = "\u2028"
        expect(view.include_gon).to eq("<script>" +
                                      "\n//<![CDATA[\n" +
                                      "window.gon={};" +
                                      "gon.global={\"str\":\"&#x2028;\"};" +
                                      "\n//]]>\n" +
                                    "</script>")
      end

      it 'outputs locally overridden value' do
        Gon.str = 'local value'
        Gon.global.str = 'global value'
        expect(view.include_gon(global_root: '')).to eq("<script>" +
                                       "\n//<![CDATA[\n" +
                                       "window.gon={};" +
                                       "gon.str=\"local value\";" +
                                       "\n//]]>\n" +
                                       "</script>")
      end

      it "includes the tag attributes in the script tag with global variables" do
        Gon.global.int = 1
        expect(view.include_gon(nonce: 'test')).to eq("<script nonce=\"test\">" +
                                      "\n//<![CDATA[\n" +
                                      "window.gon={};" +
                                      "gon.global={\"int\":1};" +
                                      "\n//]]>\n" +
                                    "</script>")
      end
    end

    context 'edge cases' do
      context "without a current_gon instance" do
        before(:each) do
          RequestStore.store[:gon] = nil
          allow(Gon).to receive(:current_gon).and_return(nil)
        end

        it "does not raise an exception" do
          expect { view.include_gon }.to_not raise_error
        end

        it 'outputs correct js' do
          expect(view.include_gon).to eq("")
        end

        it 'outputs correct js with init' do
          expect(view.include_gon(init: true)).to eq(wrap_script('window.gon={};'))
        end
      end
    end
  end

  describe '#include_gon_amd' do
    it 'is included in ActionView::Base as a helper' do
      expect(ActionView::Base.instance_methods).to include(:include_gon_amd)
    end

    it 'outputs correct js without variables' do
      expect(view.include_gon_amd).to eq( wrap_script( \
                                    'define(\'gon\',[],function(){'+
                                    'var gon={};return gon;'+
                                    '});')
      )
    end

    it 'outputs correct js with an integer' do
      Gon.int = 1

      expect(view.include_gon_amd).to eq( wrap_script(
                                    'define(\'gon\',[],function(){'+
                                    'var gon={};gon[\'int\']=1;return gon;'+
                                    '});')
      )
    end

    it 'outputs correct module name when given a namespace' do
      expect(view.include_gon_amd(namespace: 'data')).to eq(wrap_script(
                                    'define(\'data\',[],function(){'+
                                    'var gon={};return gon;'+
                                    '});')
      )
    end
  end
end
