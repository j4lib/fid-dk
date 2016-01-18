<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/" xmlns:dm2e="http://onto.dm2e.eu/schemas/dm2e/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:repox="http://repox.ist.utl.pt" xmlns:php="http://php.net/xsl">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <!-- version 1.0 -->
    <!-- Julia Beck - Universitätsbibliothek JCS Frankfurt am Main -->
    <!--
        ######################################################################
        ## XSL Transformation to convert EDM/DM2E data in XML-Format 
        ## into Solr's Update XML messages for the import with vufind.
        ## Just XSLT-version 1.0 possible in vufind!! 
        ################################################################### -->

    <xsl:template match="/">
        <xsl:element name="add">
            <xsl:for-each select="//rdf:RDF">
                <xsl:call-template name="rdf:RDF"/>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <!-- Removes duplicate places -->
    <!-- TODO -->

    <!-- ######################### metadata ######################### -->

    <xsl:template name="rdf:RDF">
        <xsl:element name="doc">
            <xsl:call-template name="metadata"/>
            <xsl:call-template name="aggregation">
                <xsl:with-param name="aggregation" select="./ore:Aggregation"/>
            </xsl:call-template>
            <xsl:call-template name="providedCHO">
                <xsl:with-param name="providedCHO" select="./edm:ProvidedCHO"/>
            </xsl:call-template>
            <xsl:call-template name="webresource">
                <xsl:with-param name="webresource" select="./edm:WebResource"/>
            </xsl:call-template>
            <xsl:call-template name="agent">
                <xsl:with-param name="agent" select="./edm:Agent"/>
            </xsl:call-template>
            <xsl:call-template name="event">
                <xsl:with-param name="event" select="./edm:Event"/>
            </xsl:call-template>
            <xsl:call-template name="place">
                <xsl:with-param name="place" select="./edm:Place"/>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <xsl:template name="metadata">
        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:text>recordtype</xsl:text>
            </xsl:attribute>
            <xsl:text>edm</xsl:text>
        </xsl:element>

        <xsl:element name="field">
            <xsl:attribute name="name">
                <xsl:text>fullrecord</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="//rdf:RDF">
                    <!-- <xsl:copy-of select="//rdf:RDF"/> -->
                    <xsl:copy-of select="php:function('VuFind::xmlAsText', //rdf:RDF)"/>
                </xsl:when>
            </xsl:choose>

        </xsl:element>
    </xsl:template>

    <!-- ######################### aggregation ######################### -->

    <xsl:template name="aggregation">
        <xsl:param name="aggregation"/>
        <xsl:variable name="id" select="$aggregation/edm:aggregatedCHO/@rdf:resource"/>
        <xsl:variable name="dataProvider" select="$aggregation/edm:dataProvider/@rdf:resource"/>
        <xsl:variable name="provider" select="$aggregation/edm:provider"/>
        <xsl:if test="$id != ''">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>id</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($id)"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$dataProvider != ''">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>dataProvider</xsl:text>
                </xsl:attribute>
                <xsl:variable name="dProvider">
                    <xsl:value-of
                        select="./foaf:Organization[@rdf:about = $dataProvider]/skos:prefLabel"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$dProvider != ''">
                        <xsl:value-of select="$dProvider"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space($dataProvider)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$provider != ''">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>provider</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($provider)"/>
            </xsl:element>
        </xsl:if>
        <xsl:for-each select="$aggregation/edm:rights[@rdf:resource != '']">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>rights</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$aggregation/edm:rights/@rdf:resource"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$aggregation/edm:rights[text() != '']">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>rights</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- ######################### providedCHO ######################### -->

    <xsl:template name="providedCHO">
        <xsl:param name="providedCHO"/>

        <xsl:if test="$providedCHO/dc:title != ''">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>title</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space($providedCHO/dc:title)"/>
            </xsl:element>
        </xsl:if>
        <xsl:for-each select="$providedCHO/dm2e:subtitle">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>subtitle</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dcterms:alternative">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>title_alt</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dcterms:isPartOf">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>isPartOf</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:description">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>description</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:language">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>language</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:format">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>description</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:type">
            <xsl:variable name="type_value">
                <xsl:choose>
                    <xsl:when test="starts-with(@rdf:resource, 'http://onto.dm2e.eu/schemas/dm2e/')">
                        <xsl:value-of select="substring(@rdf:resource, 34)"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@rdf:resource, 'http://purl.org/ontology/bibo/')">
                        <xsl:choose>
                            <xsl:when test="contains(@rdf:resource, 'Document')">
                                <xsl:text>Dokument</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(@rdf:resource, 31)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- ignore dnb parts as they already exist as literals -->
                    <xsl:when test="starts-with(@rdf:resource, 'http://dnb')"/>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="not($type_value = '')">
                <xsl:element name="field">
                    <xsl:attribute name="name">
                        <xsl:text>type</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$type_value"/>
                </xsl:element>
            </xsl:if>
            <!-- Check if Document or whatever to create TEXT IMAGE -->
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dcterms:spatial">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>place</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:creator">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>creator</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when
                        test="
                            not(contains(@rdf:resource, '#fid-dk:agent')
                            or contains(@rdf:resource, 'http://d-nb.info/gnd/'))">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="normalize-space(../../*[@rdf:about = current()/@rdf:resource]/skos:prefLabel)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:contributor">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>contributor</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when
                        test="
                            not(contains(@rdf:resource, '#fid-dk:agent')
                            or contains(@rdf:resource, 'http://d-nb.info/gnd/'))">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="normalize-space(../../*[@rdf:about = current()/@rdf:resource]/skos:prefLabel)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dcterms:issued">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>issued</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="not(contains(@rdf:resource, '#fid-dk:timespan'))">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="normalize-space(../../*[@rdf:about = current()/@rdf:resource]/skos:prefLabel)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dc:publisher">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>publisher</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when
                        test="
                            not(contains(@rdf:resource, '#fid-dk:agent')
                            or contains(@rdf:resource, 'http://d-nb.info/gnd/'))">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="normalize-space(../../*[@rdf:about = current()/@rdf:resource])"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="$providedCHO/dcterms:tableOfContents">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>toc</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- ######################### webresource ######################### -->

    <xsl:template name="webresource">
        <xsl:param name="webresource"/>
        <xsl:for-each select="$webresource/dc:format">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>edmType</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="contains(., 'text')">
                        <xsl:text>TEXT</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'image')">
                        <xsl:text>IMAGE</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
        <!--
        <xsl:for-each select="$webresource/dc:rights">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>rights</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element>
        </xsl:for-each>
        -->
    </xsl:template>

    <!-- ######################### agent ######################### -->
    <xsl:template name="agent"/>

    <!-- ######################### event ######################### -->
    <xsl:template name="event"/>

    <!-- ######################### place ######################### -->
    <xsl:template name="place">
        <xsl:param name="place"/>
        <xsl:for-each select="$place/skos:prefLabel">
            <xsl:element name="field">
                <xsl:attribute name="name">
                    <xsl:text>place</xsl:text>
                </xsl:attribute>
                <xsl:choose>
                    <!-- In case the place is given in [], remove them -->
                    <xsl:when test="starts-with(., '[') and (substring(., string-length(.)) = ']')">
                        <xsl:message>
                            <xsl:value-of select="string-length()"/>
                        </xsl:message>
                        <xsl:value-of select="substring(., 2, string-length(.) - 2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
