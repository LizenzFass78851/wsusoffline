<?xml version="1.0"?>
<!--
     Author: H. Buhrmester, 2020
     Filename: extract-revision-and-update-ids-dotnet.xsl

     This file selects updates by their Product Ids:
     Windows Server 2008 = ba0ae9cc-5f01-40b4-ac3f-50192b5d6aaf
     Windows 7 = bfe5b177-a086-47a0-b102-097e4fa1f807
     Windows Server 2008 R2 = fdfe8200-9d98-44ba-a12a-772282bf60ef

     It extracts the following fields:
     Field 1: Bundle RevisionId
     Field 2: UpdateId
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:__="http://schemas.microsoft.com/msus/2004/02/OfflineSync" version="1.0">
  <xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
  <xsl:template match="/">
    <xsl:for-each select="__:OfflineSyncPackage/__:Updates/__:Update/__:Categories/__:Category[@Type='Product']">
      <xsl:if test="contains(@Id, 'ba0ae9cc-5f01-40b4-ac3f-50192b5d6aaf')
                 or contains(@Id, 'bfe5b177-a086-47a0-b102-097e4fa1f807')
                 or contains(@Id, 'fdfe8200-9d98-44ba-a12a-772282bf60ef')">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="../../@RevisionId"/>
        <xsl:text>#,</xsl:text>
        <xsl:value-of select="../../@UpdateId"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
