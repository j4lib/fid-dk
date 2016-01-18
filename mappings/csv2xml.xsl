<?xml version="1.0" encoding="UTF-8"?>
<!-- This is a slightly different version of Andrew Welch's CSV to XML mapping: 
    http://andrewjwelch.com/code/xslt/csv/csv-to-xml_v2.html -->
<!-- Usage: java -cp /opt/saxon/saxon9he.jar net.sf.saxon.Transform -o:output.xml 
    -it:main /.../csv2edm.xsl pathToCSV=file:/.../Ebert.csv -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="fn"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xs fn">

    <xsl:output indent="yes" encoding="UTF-8"/>
 
   <!-- path from command line -->
    <xsl:param name="pathToCSV"/>

    <xsl:function name="fn:getTokens" as="xs:string+">
        <xsl:param name="str" as="xs:string"/>
        <xsl:analyze-string select="concat($str, ',')"
            regex="((&quot;[^&quot;]*&quot;)+|[^,]*),">
            <xsl:matching-substring>
                <xsl:sequence
                    select="replace(regex-group(1), &quot;^&quot;&quot;|&quot;&quot;$|(&quot;&quot;)&quot;&quot;&quot;, &quot;$1&quot;)"
                />
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:template match="/" name="main">
        <xsl:choose>
            <xsl:when test="unparsed-text-available($pathToCSV)">
                <xsl:variable name="csv" select="unparsed-text($pathToCSV)"/>
                <!-- CSV's rows are seperated by '\n'. Important that CSV-file is normalized in advance. -->
                <xsl:variable name="seq" select="tokenize($csv, '\n')" as="xs:string+"/>
                <!-- needed to remove last empty unit -->
                <xsl:variable name="lines" select="remove($seq,count($seq))" as="xs:string+"/>
                <xsl:variable name="elemNames" select="fn:getTokens($lines[1])" as="xs:string+"/>
                <root>
                    <xsl:for-each select="$lines[position() &gt; 1]">
                        <record>
                            <xsl:variable name="lineItems" select="fn:getTokens(.)" as="xs:string+"/>

                            <xsl:for-each select="$elemNames">
                                <xsl:variable name="pos" select="position()"/>
                                <elem name="{.}">
                                    <xsl:value-of select="$lineItems[$pos]"/>
                                </elem>
                            </xsl:for-each>
                        </record>
                    </xsl:for-each>
                </root>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Cannot locate : </xsl:text>
                <xsl:value-of select="$pathToCSV"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
