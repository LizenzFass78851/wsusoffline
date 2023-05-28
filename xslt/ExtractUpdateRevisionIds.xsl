<!-- Author: T. Wittrock, Kiel -->
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" encoding="UTF-8"/>
                        
<xsl:template match="*">
  <xsl:choose>
    <xsl:when test="name()='Update'">
      <xsl:text>_</xsl:text>
      <xsl:value-of select="@RevisionId"/>
      <xsl:text>_&#10;</xsl:text>
    </xsl:when>
    <xsl:when test="name()='FileLocations'">
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="*"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>
