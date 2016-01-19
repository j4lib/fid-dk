<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common">

    <!-- version 1.0 -->
    <!-- Julia Beck - Universitätsbibliothek JCS Frankfurt am Main -->
    <!--
        ######################################################################
        ## XSL Transformation to reorder Filemaker XML-data 
        ## into a normal XML structure where the field has a certain label other than ROW or COL.
        ################################################################### -->

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="createFiles">yes</xsl:param>

    <xsl:template match="/">
        <xsl:variable name="origin">
            <xsl:copy-of select="substring-before(tokenize(base-uri(),'/')[last()],'.xml')"></xsl:copy-of>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$createFiles = 'yes'">
                <!-- <xsl:result-document href="base-uri()"> -->
                <xsl:element name="list">
                    <!-- reorder the filemaker structure -->
                    <xsl:for-each select="//ROW">
                        <xsl:variable name="filename">
                            <xsl:value-of select="concat(substring-before(base-uri(),'.xml'), '/', $origin, '_', position(),'.xml')"/>
                        </xsl:variable>
                        <xsl:result-document href="{$filename}">
                            <xsl:apply-templates select="."/>
                        </xsl:result-document>
                    </xsl:for-each>
                </xsl:element>
                <!-- </xsl:result-document> -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="list">
                    <!-- reorder the filemaker structure -->
                    <xsl:apply-templates select="//ROW"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- reorder the filemaker structure to assign the values to the right metadata tags -->
    <xsl:template match="//ROW">
        <xsl:element name="record">
            <!-- get the record id -->
            <xsl:attribute name="id">
                <xsl:value-of select="@RECORDID"/>
            </xsl:attribute>
            <!-- search for the right metadata tag according to the data's position in the row -->
            <xsl:for-each select="COL">
                <xsl:if test="not(DATA = '')">
                    <xsl:variable name="field">
                        <xsl:value-of
                            select="normalize-space(translate(subsequence(../../../METADATA/FIELD/@NAME, position(), 1), ' ', '_'))"
                        />
                    </xsl:variable>
                    <xsl:for-each select="DATA">
                        <xsl:if test="not(. = '')">
                            <xsl:element name="{$field}">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>

    </xsl:template>

</xsl:stylesheet>
