<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:param name="color"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="context">
    <image source="sbk:/style/graphics/section.gif">
      <xsl:apply-templates/>
    </image>
  </xsl:template>

  <xsl:template match="parameter">
    <xsl:if test="@name='label'">
      <text font="Arial" size="12" x="4" y="2" halign="left"
            valign="top" color="{$color}" style="bold" text="{@value}"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
