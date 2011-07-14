<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:func="http://exslt.org/functions" xmlns:math="http://exslt.org/math" xmlns:str="http://exslt.org/strings"
    xmlns:dyn="http://exslt.org/dynamic"
    extension-element-prefixes="func math str dyn">
  <xsl:output indent="yes" />
  
  <!-- User variables --> 
  <xsl:variable name="document_version" select="2.0" />
  <xsl:variable name="insert_sample_menu" select="true()" />
  
  <func:function name="func:dec2hex">
    <xsl:param name="dec" />
    <xsl:param name="level" select="0" />
    <xsl:variable name="divisor" select="math:power(16, $level)"/>
    <xsl:variable name="digit" select="floor($dec div $divisor) mod 16"/>
    <xsl:variable name="s" select="substring('0123456789ABCDEF', $digit + 1, 1)"/>
    <xsl:choose>
      <xsl:when test="$level=6">
        <func:result select="'#'" />
      </xsl:when>
      <xsl:otherwise>
        <func:result select="concat(func:dec2hex($dec, $level + 1), $s)" />
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
    
  <xsl:template match="document">
    <xsl:copy>
      <xsl:attribute name="version"><xsl:value-of select="$document_version" /></xsl:attribute>
            
      <resources>
        <xsl:apply-templates select="." mode="resources" />
      </resources>
      
      <menu>
        <!-- We usually assign dynamically -->
        <xsl:if test="$insert_sample_menu">
        	<item label="File">
        		<item label="New" url="template.xml" action="redirect" />
        		<item label="Open" url="fixtures/document-list.xml" action="open" />
        		<item label="Save" url="save.do" action="save" />
        		<item label="Save as.." url="test/fixtures/dummyaction" action="saveas" />
        		<item label="Quit" url="javascript:window.close()" action="redirect" />
        	</item>
          <item label="Edit">
            <xsl:apply-templates select="style"/>
          </item>
          <item label="Output">
      			<item label="Publish" url="publish.do" action="send" />
      		</item>
      		<item label="Compliance">
      			<item label="Send!" url="compliance.do" action="send" />
      		</item>
        </xsl:if>
      </menu>
      
      <pages>
        <xsl:apply-templates select="node()[name() != 'style']" mode="pages" />
      </pages>
      <texts>
        <xsl:apply-templates select="node()[name() != 'style']" mode="texts"/>
      </texts>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="document" mode="resources">
    <xsl:for-each select="//page">
      <xsl:variable name="n" select="concat('bkg', @number)" />
      <resource type="bkg"><xsl:attribute name="id"><xsl:value-of select="$n" /></xsl:attribute></resource>
    </xsl:for-each>
    <xsl:for-each select="//style">
      <resource type="font"><xsl:attribute name="id"><xsl:value-of select="@font" /></xsl:attribute></resource>
    </xsl:for-each>
    <xsl:for-each select="//block[starts-with(@name,'photo')]">
      <resource type="photo"><xsl:attribute name="id"><xsl:value-of select="@contents" /></xsl:attribute></resource>
    </xsl:for-each>      
  </xsl:template>
  
  <xsl:template match="page" mode="pages">
    <xsl:copy>
      <xsl:attribute name="background"><xsl:value-of select="concat('bkg', @number)" /></xsl:attribute>
      <xsl:apply-templates select="@*|node()" mode="pages" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="block[starts-with(@name, 'photo')]" mode="pages">
    <!-- <block actualwidth="90" name="photo3" x="487" y="710" width="90" height="37" contents="company_logo" anchor="1" pdfxheight="0" static="yes"/> -->
    <!-- to -->
    <!-- <block type="photo" id="3" boxX="0" boxY="220" boxWidth="362" boxHeight="129" width="170" src="photo" align="middlecenter" /> -->
    <block>
      <xsl:attribute name="type">photo</xsl:attribute>
      <xsl:attribute name="id"><xsl:value-of select="substring(@name, 6)"/></xsl:attribute>
      <xsl:attribute name="src"><xsl:value-of select="@contents"/></xsl:attribute>
      <xsl:attribute name="static"><xsl:value-of select="@static"/></xsl:attribute>
      <xsl:attribute name="multipage"><xsl:value-of select="@multipage"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="@actualwidth"/></xsl:attribute>
      <xsl:attribute name="boxX"><xsl:value-of select="@x"/></xsl:attribute>
      <xsl:attribute name="boxY"><xsl:value-of select="@y"/></xsl:attribute>
      <xsl:attribute name="boxWidth"><xsl:value-of select="@width"/></xsl:attribute>
      <xsl:attribute name="boxHeight"><xsl:value-of select="@height"/></xsl:attribute>
      <xsl:choose>
        <xsl:when test="@anchor='0'"><xsl:attribute name="align">topleft</xsl:attribute></xsl:when>
        <xsl:when test="@anchor='1'"><xsl:attribute name="align">bottomleft</xsl:attribute></xsl:when>
        <xsl:when test="@anchor='2'"><xsl:attribute name="align">topright</xsl:attribute></xsl:when>
        <xsl:when test="@anchor='3'"><xsl:attribute name="align">bottomright</xsl:attribute></xsl:when>
        <xsl:when test="@anchor='4'"><xsl:attribute name="align">middlecenter</xsl:attribute></xsl:when>
      </xsl:choose>
    </block>
  </xsl:template>
  
  <xsl:template match="block[starts-with(@name, 'text')]" mode="pages">
    <!-- <block name="text2_2" x="322" y="348" width="252" height="340" pdfxheight="4.5" /> -->
    <!-- to -->
    <!-- <block type="text" x="250" y="145" width="385" height="229" text="1" index="2">    -->
    <block>
      <xsl:attribute name="type">text</xsl:attribute>
      <xsl:attribute name="text"><xsl:value-of select="substring(str:split(@name, '_')[1], 5)"/></xsl:attribute>
      <xsl:attribute name="static"><xsl:value-of select="@static"/></xsl:attribute>
      <xsl:attribute name="index"><xsl:value-of select="str:split(@name, '_')[2]"/></xsl:attribute>
      <xsl:attribute name="x"><xsl:value-of select="@x"/></xsl:attribute>
      <xsl:attribute name="y"><xsl:value-of select="@y"/></xsl:attribute>
      <xsl:attribute name="width"><xsl:value-of select="@width"/></xsl:attribute>
      <xsl:attribute name="height"><xsl:value-of select="@height"/></xsl:attribute>
      <xsl:attribute name="multipage"><xsl:value-of select="@multipage"/></xsl:attribute>
    </block>
  </xsl:template>
  
  <!-- Ignore these elements/attributes -->
  <xsl:template match="content" mode="pages" />
  
  <xsl:template match="content" mode="texts">
    <text>
      <xsl:attribute name="id"><xsl:value-of select="@number"/></xsl:attribute>
      <xsl:apply-templates select="p" mode="p"/>
    </text>
  </xsl:template>
  
  <xsl:template match="p" mode="p">
    <xsl:variable name="class" select="@class" />
    <xsl:variable name="style" select="//style[@name=$class]" />
    <p>
      <xsl:attribute name="align"><xsl:choose><xsl:when test="@center='1'">center</xsl:when><xsl:otherwise>left</xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:apply-templates select="." mode="b"/>
    </p>
  </xsl:template>
  
  <xsl:template match="p" mode="b">
    <xsl:variable name="class" select="@class" />
    <xsl:variable name="style" select="//style[@name=$class]" />
    <xsl:choose>
      <xsl:when test="$style/@bold='1' and text()[normalize-space(.)]">
        <b><xsl:apply-templates select="." mode="i"/></b>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="i"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="p" mode="i">
    <xsl:variable name="class" select="@class" />
    <xsl:variable name="style" select="//style[@name=$class]" />
    <xsl:choose>
      <xsl:when test="$style/@italic='1' and text()[normalize-space(.)]">
        <i><xsl:apply-templates select="." mode="etc"/></i>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="etc"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="p" mode="etc">
    <xsl:variable name="class" select="@class" />
    <xsl:variable name="style" select="//style[@name=$class]" />
    <font>
      <xsl:attribute name="size"><xsl:value-of select="$style/@size" /></xsl:attribute>
      <xsl:attribute name="face"><xsl:value-of select="translate($style/@font, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" /></xsl:attribute>
      <xsl:attribute name="color"><xsl:value-of select="func:dec2hex($style/@color)" /></xsl:attribute>
      <textformat>
        <xsl:value-of select="." />
      </textformat>
    </font>
  </xsl:template>
  
  <xsl:template match="text()" mode="innerxml"><xsl:value-of select="."/></xsl:template>
  <xsl:template match="node()" mode="innerxml">&lt;<xsl:value-of select="name()"/><xsl:apply-templates select="@*" mode="innerxml"/>&gt;<xsl:apply-templates select="text()" mode="innerxml"/>&lt;/<xsl:value-of select="name()"/>&gt;</xsl:template>
  <xsl:template match="@*" mode="innerxml"><xsl:text> </xsl:text><xsl:value-of select="name()"/>="<xsl:value-of select="."/>"</xsl:template>
  
  <xsl:template match="style">
    <item>
      <!-- Label -->
      <xsl:attribute name="label"><xsl:value-of select="@name" /></xsl:attribute>
      <xsl:attribute name="action">format</xsl:attribute>
      
      <!-- Boolean attributes -->
      <xsl:attribute name="bold"><xsl:choose><xsl:when test="@bold='1'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:attribute name="italic"><xsl:choose><xsl:when test="@italic='1'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose></xsl:attribute>
      
      <!-- Integer attributes -->
      <xsl:attribute name="color"><xsl:value-of select="@color" /></xsl:attribute>
      <xsl:attribute name="leading"><xsl:value-of select="@leading" /></xsl:attribute>
      <xsl:attribute name="leftMargin"><xsl:value-of select="@x" /></xsl:attribute>
      <xsl:attribute name="size"><xsl:value-of select="@size" /></xsl:attribute>
            
      <!-- String attributes -->
      <xsl:attribute name="align"><xsl:choose><xsl:when test="@center='1'">center</xsl:when><xsl:otherwise>left</xsl:otherwise></xsl:choose></xsl:attribute>
      <xsl:attribute name="font"><xsl:value-of select="translate(@font, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" /></xsl:attribute>
    </item>
  </xsl:template>

  <xsl:template match="@*|node()" mode="pages">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>