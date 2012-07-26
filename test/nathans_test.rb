require 'rubygems'
require 'xml'
require 'fn_document'

@background_path = "/Users/nathan/github/fn_document/test/assets/pdf_background_2.pdf"
@save_path = "/Users/nathan/Desktop/temp.pdf"

@xml_string = ''
@xml_string += '<root>'
# @xml_string += '<set_parameter key="license" value="L700202-010000-116496-QXVFH2-2Y4UE2"/>'
@xml_string += '<set_parameter key="resourcefile" value="/Users/nathan/rails/myfasi/public/fonts/pdflib.upr"/>'
@xml_string += '<set_parameter key="hypertextencoding" value="unicode"/>'
@xml_string += '<set_parameter key="textformat" value="utf8"/>'
@xml_string += '<open_pdi file="'+@background_path+'" assigns="pdi">'
@xml_string += '<begin_document file="'+@save_path+'" compatibility="1.5">'
@xml_string += '<set_parameter key="topdown" value="true"/>'
@xml_string += '<create_textflow assigns="flow-1"><![CDATA[<fontname=Arial encoding=unicode fontsize=10><encoding=unicode '
@xml_string += 'embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% maxspacing=100% kerning=true charref=true fontname={Myriad}'
@xml_string += ' fontsize=12 leftindent=0 rightindent=0 leading=14 fillcolor={rgb 0.0 0.0 0.0} parindent=0 underline=false alignment=left>'
@xml_string += 'Call John Franczak at<encoding=unicode embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% maxspacing=100% '
@xml_string += 'kerning=true charref=true fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 leading=14 fillcolor={rgb '
@xml_string += '0.0705882352941176 0.596078431372549 0.317647058823529} parindent=0 underline=false alignment=left> 775-831-6000 '
@xml_string += '<encoding=unicode embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% maxspacing=100% kerning=true charref=true '
@xml_string += 'fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 leading=14 fillcolor={rgb 0.0 0.0 0.0} parindent=0 underline=false '
@xml_string += 'alignment=left>or visit us at<encoding=unicode embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% '
@xml_string += 'maxspacing=100% kerning=true charref=true fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 leading=14 '
@xml_string += 'fillcolor={rgb 0.0705882352941176 0.596078431372549 0.317647058823529} parindent=0 underline=false alignment=left> '
@xml_string += 'www.jfwealthmanagement.com <encoding=unicode embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% '
@xml_string += 'maxspacing=100% kerning=true charref=true fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 leading=14 '
@xml_string += 'fillcolor={rgb 0.0 0.0 0.0} parindent=0 underline=false alignment=left>to learn more about how the Greenbook '
@xml_string += 'program may be able to help you!<nextparagraph>]]></create_textflow>'
@xml_string += '<begin_page_ext width="594" height="793" number="1">'
@xml_string += '<open_pdi_page pdi="{pdi}" assigns="page" number="1">'
@xml_string += '<fit_pdi_page page="{page}"/>'
@xml_string += '<watermark text="Not compliance approved."/>'
@xml_string += '</open_pdi_page>'
@xml_string += '<load_image file="/Users/nathan/github/fn_document/test/assets/logo.jpg" '
@xml_string += 'assigns="tmp"/>'
@xml_string += '<fit_image y="570" image="{tmp}" fitmethod="meet" x="77" boxsize="71 48.99"/>'
@xml_string += '</begin_page_ext>'
@xml_string += '<create_textflow assigns="flow-1-6"><![CDATA[<fontname=Arial encoding=unicode fontsize=10><encoding=unicode '
@xml_string += 'embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% maxspacing=100% kerning=true charref=true fontname={Myriad} '
@xml_string += 'fontsize=12 leftindent=0 rightindent=0 leading=14 fillcolor={rgb 0.0 0.0 0.0} parindent=0 underline=false alignment=left>Call '
@xml_string += 'John Franczak at<encoding=unicode embedding=true adjustmethod=nofit nofitlimit=100% minspacing=100% maxspacing=100% kerning=true '
@xml_string += 'charref=true fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 leading=14 fillcolor={rgb 0.0705882352941176 0.596078431372549 '
@xml_string += '0.317647058823529} parindent=0 underline=false alignment=left> 775-831-6000 <encoding=unicode embedding=true adjustmethod=nofit '
@xml_string += 'nofitlimit=100% minspacing=100% maxspacing=100% kerning=true charref=true fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 '
@xml_string += 'leading=14 fillcolor={rgb 0.0 0.0 0.0} parindent=0 underline=false alignment=left>or visit us at<encoding=unicode embedding=true '
@xml_string += 'adjustmethod=nofit nofitlimit=100% minspacing=100% maxspacing=100% kerning=true charref=true fontname={Myriad} fontsize=12 '
@xml_string += 'leftindent=0 rightindent=0 leading=14 fillcolor={rgb 0.0705882352941176 0.596078431372549 0.317647058823529} parindent=0 '
@xml_string += 'underline=false alignment=left> www.jfwealthmanagement.com <encoding=unicode embedding=true adjustmethod=nofit nofitlimit=100% '
@xml_string += 'minspacing=100% maxspacing=100% kerning=true charref=true fontname={Myriad} fontsize=12 leftindent=0 rightindent=0 leading=14 '
@xml_string += 'fillcolor={rgb 0.0 0.0 0.0} parindent=0 underline=false alignment=left>to learn more about how the Greenbook program may be '
@xml_string += 'able to help you!<nextparagraph>]]></create_textflow>'
@xml_string += '<resume_page pagenumber="1">'
@xml_string += '<fit_textflow y="575" flow="{flow-1-6}" x2="277.0" y2="635.0" x="62"/>'
@xml_string += '</resume_page>'
@xml_string += '<end_page_ext pagenumber="1"/>'
@xml_string += '</begin_document>'
@xml_string += '</open_pdi>'
@xml_string += '</root>'

@context_doc = LibXML::XML::Document.string(@xml_string)
puts @context_doc.root.children[3].children[0].children[2].children[0][:number] # Should be "1"

@fn_pdf = FN::PDF::Writer.new
@fn_pdf.write_xml(@context_doc,@save_path,true)

# 
# >> @fn_doc_options[:save_as]
# => "/tmp/output20111020-28153-124kzy1-0"
# >> @fn_doc_options[:save_as].class
# => String
# >> 
