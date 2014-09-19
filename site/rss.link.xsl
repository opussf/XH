<?xml version='1.0' encoding='ISO-8859-1'?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html"/>

	<xsl:template match="/">
		<xsl:apply-templates select="rss/channel/item[1]"/>
	</xsl:template>

	<xsl:template match="item">
		<xsl:element name="a">
			<xsl:attribute name="href"><xsl:value-of select="link"/></xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="pubDate"/></xsl:attribute>
			<xsl:value-of select="title"/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>