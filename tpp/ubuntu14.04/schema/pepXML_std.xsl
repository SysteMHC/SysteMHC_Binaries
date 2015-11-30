<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:pepx="http://regis-web.systemsbiology.net/pepXML">
	<xsl:variable name="cgi_home">/tpp/cgi-bin/</xsl:variable>
	<xsl:variable name="xslt">/usr/bin/xsltproc</xsl:variable>
	<!-- Added new variables Improvements by Pat Moss 11.23.04 -->
	
	<xsl:variable name="Search_engine" select="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/@search_engine"/>
		
	<!-- Moved the assignment to the top node since we are doing this a bunch of times.  Make sure this is the correct noded -->
	
	<xsl:variable name="basename" select="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/@base_name"/>
	<xsl:variable name="summaryxml" select="/pepx:msms_pipeline_analysis/@summary_xml"/>
	<xsl:variable name="Database">
			<xsl:choose>
				<xsl:when test="/pepx:msms_pipeline_analysis/pepx:analysis_timestamp[analysis='database_refresh']">
					<xsl:value-of 
						select="/pepx:msms_pipeline_analysis/pepx:analysis_timestamp[analysis='database_refresh']/pepx:database_refresh_timestamp/@database"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/pepx:search_database/@local_path"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	<xsl:variable name="enzyme" select="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:sample_enzyme/@name"/>
	<xsl:variable name="minntt">
			<xsl:choose>
				<xsl:when 
					test="/pepx:msms_pipeline_analysis/pepx:search_summary/pepx:enzymatic_search_constraint and /pepx:msms_pipeline_analysis/pepx:search_summary/pepx:enzymatic_search_constraint/@enzyme=/pepx:msms_pipeline_analysis/@sample_enzyme">
					<xsl:value-of 
						select="/pepx:msms_pipeline_analysis/pepx:search_summary/pepx:enzymatic_search_constraint/@min_number_termini"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="comet_md5_check_sum">
			<xsl:if test="/pepx:msms_pipeline_analysis/pepx:search_summary/@search_engine='COMET'">
				<xsl:value-of 
					select="/pepx:msms_pipeline_analysis/pepx:search_summary/pepx:parameter[@name='md5_check_sum']/@value"/>
			</xsl:if>
		</xsl:variable>
	<xsl:variable name="aa_mods">
			<xsl:for-each select="/pepx:msms_pipeline_analysis/pepx:search_summary/pepx:aminoacid_modification">
				<xsl:value-of select="@aminoacid"/>
					<xsl:if test="@symbol">
						<xsl:value-of select="@symbol"/>
					</xsl:if>
				-
				<xsl:value-of select="@mass"/>
				:
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="term_mods">
			<xsl:for-each select="/pepx:msms_pipeline_analysis/pepx:search_summary/pepx:terminal_modification">
				<xsl:value-of select="@terminus"/><xsl:if 
				test="@symbol"><xsl:value-of 
				select="@symbol"/></xsl:if>-<xsl:value-of 
				select="@mass"/>:</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="masstype">
			<xsl:if test="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/@precursor_mass_type='average'">
				0</xsl:if>
			<xsl:if test="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/@precursor_mass_type='monoisotopic'">
				1</xsl:if>
		</xsl:variable>
		
		
		
		
		
			
			
	<xsl:variable name="tab">
		<xsl:text>&#x09;</xsl:text>
	</xsl:variable>
	<xsl:variable name="newline">
		<xsl:text>
		</xsl:text>
	</xsl:variable>
	<xsl:key name="search_engine" 
		match="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/@search_engine" use="."/>
	<xsl:template match="pepx:msms_pipeline_analysis">
<HTML><BODY BGCOLOR="white" OnLoad="self.focus()">
<HEAD><TITLE>Trans-Proteomic Pipeline pepXML Viewer</TITLE></HEAD><table width="100%" border="3" BGCOLOR="#8FBC6F"><tr><td align="center"><pre>

Trans-Proteomic Pipeline pepXML Viewer     A.Keller 7.9.03 
								

Search Engine: <A TARGET="Win2" HREF="{$cgi_home}show_search_params.pl?xmlfile={pepx:msms_run_summary/@base_name}.xml&amp;basename={pepx:msms_run_summary/@base_name}&amp;engine={pepx:msms_run_summary/pepx:search_summary/@search_engine}&amp;xslt={$xslt}"><xsl:value-of select="pepx:msms_run_summary/pepx:search_summary/@search_engine"/></A> 
Database: <xsl:value-of select="pepx:msms_run_summary/pepx:search_summary/pepx:search_database/@local_path"/> 
Sample Enzyme: <xsl:value-of select="pepx:msms_run_summary/pepx:sample_enzyme/@name"/>

</pre><pre>
<p/>

<FORM ACTION="{$cgi_home}Pep3D_xml.cgi" METHOD="POST" TARGET="Win2"><input type="hidden" name="mzRange" value="Full"/><input type="hidden" name="mzGrid" value="3"/><input type="hidden" name="mzImgGrid" value="1"/><input type="hidden" name="scanRange" value="Full"/><input type="hidden" name="scanGrid" value="0.25"/><input type="hidden" name="scanImgGrid" value="2"/><input type="hidden" name="peakRange" value="unit of background"/><input type="hidden" name="peakLower" value="1"/><input type="hidden" name="peakUpper" value="20"/><input type="hidden" name="pepDisplay" value="All"/><input type="hidden" name="pepImgGrid" value="2"/><input type="hidden" name="probLower" value="0.5"/><input type="hidden" name="probUpper" value="1.0"/><input type="hidden" name="function" value="Linear"/><input type="hidden" name="image" value="Full"/><INPUT TYPE="SUBMIT" name="submit" VALUE="Generate Pep3D image"/><INPUT TYPE="SUBMIT" name="submit" VALUE="Save as"/> <input type="text" name="saveFile" size="10" value="Pep3D.htm"/><input type="hidden" name="display_all" value="yes"/><input type="hidden" name="htmFile" value="{$summaryxml}"/></FORM></pre>
						</td>
					</tr>
				</table>


				<xsl:value-of select="$newline"/>
				<pre><xsl:text> </xsl:text><font color="red"><xsl:value-of select="count(pepx:msms_run_summary/pepx:spectrum_query)"/> entries retrieved from <xsl:value-of select="pepx:msms_run_summary/@base_name"/>.xml</font></pre>
				<table cellpadding="2" bgcolor="white" 
					style="font-family: 'Courier New', Courier, mono; font-size: 10pt;">
					<xsl:comment>start</xsl:comment>
					<tr>
						<td>
							<font color="brown">
								<b>index</b>
							</font>
							<xsl:text>
							</xsl:text>
						</td>
						<td>
							<font color="brown">
								<b>spectrum</b>
							</font>
							<xsl:text>
							</xsl:text>
						</td>
						<td>
							<table cellpadding="2" bgcolor="white" 
								style="font-family: 'Courier New', Courier, mono; font-size: 10pt;">
								<TR>
									<xsl:if 
										test="count(pepx:msms_run_summary/pepx:search_summary/@search_engine[generate-id()=generate-id(key('search_engine',.)[1])])='1'">
										<xsl:choose>

											<!-- Choose the program that produced this data -->
											<!-- SEQUEST -->
											<xsl:when 
												test="$Search_engine='SEQUEST'">
												<td>
													<font color="brown">
														<b>xcorr</b>
													</font>
												</td>
												<td>
													<font color="brown">
														<b>deltacn</b>
													</font>
												</td>
												<td>
													<font color="brown">
														<b>sprank</b>
													</font>
												</td>
											</xsl:when>

											<!-- MASCOT -->
											<xsl:when 
												test="$Search_engine='MASCOT'">
												<td width="50">
													<font color="brown">
														<b>ionscore</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>id score</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>homology score</b>
													</font>
												</td>
											</xsl:when>
											
											<!-- PHENYX -->											<!-- MASCOT -->
											<xsl:when 
												test="$Search_engine='PHENYX'">
												<td width="50">
													<font color="brown">
														<b>zscore</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>origScore</b>
													</font>
												</td>
											</xsl:when>
											
											<!-- Tandem -->
											<xsl:when 
												test="$Search_engine='X! Tandem'">
												<td width="50">
													<font color="brown">
														<b>hyperscore</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>nextscore</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>expect</b>
													</font>
												</td>
											</xsl:when>

												<!-- COMET -->
											<xsl:when 
												test="$Search_engine='COMET'">
												<td width="50">
													<font color="brown">
														<b>dot product</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>delta</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>zscore</b>
													</font>
												</td>
											</xsl:when>
											<xsl:when 
												test="$Search_engine='PROBID'">
												<td width="50">
													<font color="brown">
														<b>bays score</b>
													</font>
												</td>
												<td width="50">
													<font color="brown">
														<b>z score</b>
													</font>
												</td>
											</xsl:when>
											<xsl:otherwise>
												<font color="brown">
													<b>search scores</b>
												</font>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
									<xsl:if 
										test="count(pepx:msms_run_summary/pepx:search_summary/@search_engine[generate-id()=generate-id(key('search_engine',.)[1])])&gt;'1'">
										<td>
											<font color="brown">
												<b>search scores</b>
											</font>
										</td>
									</xsl:if>
								</TR>
							</table>
						</td>
						<td>
							<font color="brown">
								<b>m ions</b>
							</font>
							<xsl:text>
							</xsl:text>
						</td>
						<td>
							<font color="brown">
								<b>peptide</b>
							</font>
							<xsl:text>
							</xsl:text>
						</td>
						<td>
							<font color="brown">
								<b>protein</b>
							</font>
							<xsl:text>
							</xsl:text>
						</td>
						<td>
							<font color="brown">
								<b>ntt</b>
							</font>
							<xsl:text>
							</xsl:text>
						</td>
					</tr>
					<xsl:apply-templates select="pepx:msms_run_summary/pepx:spectrum_query">

					<!-- NOT SURE IF WE NEED TO SORT SINCE THE INDEX ATTRIBUTES APPEAR TO BE IN ORDER FOR THIS DATA SET 
						<xsl:sort select="@index" order="ascending" 
							data-type="number"/> -->

					</xsl:apply-templates>
				</table>
			</BODY>
		</HTML>

	</xsl:template>
	
	<xsl:template match="pepx:spectrum_query">
		
		
		<xsl:variable name="xpress_spec" select="@spectrum"/>
		<xsl:variable name="index" select="@index"/>
		<xsl:variable name="Peptide" select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide"/>
		<xsl:variable name="StrippedPeptide" 
			select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide"/>
		<xsl:variable name="Protein" select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@protein"/>
		<xsl:variable name="pep_mass" select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@calc_neutral_pep_mass"/>
		
		
		<xsl:variable name="PeptideMods">
			<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info">
				<xsl:if 
					test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_nterm_mass">
					n[<xsl:value-of 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_nterm_mass"/>]</xsl:if>
				<xsl:if 
					test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_cterm_mass">
					c[<xsl:value-of 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_cterm_mass"/>]</xsl:if>
				<xsl:for-each 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass">
					<xsl:value-of select="@position"/>[<xsl:value-of 
					select="@mass"/>]</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="PeptideMods2">
			<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info">
				<xsl:if 
					test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_nterm_mass">
					ModN=<xsl:value-of 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_nterm_mass"/>&amp;</xsl:if>
				<xsl:if 
					test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_cterm_mass">
					ModC=<xsl:value-of 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_cterm_mass"/>&amp;</xsl:if>
				<xsl:for-each 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass">
					Mod<xsl:value-of select="@position"/>=<xsl:value-of 
					select="@mass"/>&amp;</xsl:for-each>
			</xsl:if>
		</xsl:variable>
		
		<tr>
			<td>
				<nobr>
					<xsl:value-of select="@index"/>
					<xsl:text>
					</xsl:text>
				</nobr>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="$Search_engine='SEQUEST'">
						<A TARGET="Win1" 
							HREF="{$cgi_home}sequest-tgz-out.cgi?OutFile={$basename}/{$xpress_spec}.out">
							<xsl:value-of select="@spectrum"/>
						</A>
					</xsl:when>
					<xsl:when test="$Search_engine='MASCOT'">
						<A TARGET="Win1" 
							HREF="{$cgi_home}mascotout.pl?OutFile={$basename}/{$xpress_spec}.out">
							<xsl:value-of select="@spectrum"/>
						</A>
					</xsl:when>
					<xsl:when test="$Search_engine='PHENYX'">
						<xsl:variable name="phenxml" select="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/pepx:parameter[@name='output, path']/@value"/>
						<A TARGET="Win1" 
							HREF="{$phenxml}">
							<xsl:value-of select="@spectrum"/>
						</A>
					</xsl:when>
					<xsl:when test="$Search_engine='X! Tandem'">
						<xsl:variable name="tandxml" select="/pepx:msms_pipeline_analysis/pepx:msms_run_summary/pepx:search_summary/pepx:parameter[@name='output, path']/@value"/>
						<A TARGET="Win1" 
							HREF="{$tandxml}">
							<xsl:value-of select="@spectrum"/>
						</A>
					</xsl:when>
					<xsl:when test="$Search_engine='COMET'">
						<A TARGET="Win1" 
							HREF="{$cgi_home}cometresult.cgi?TarFile={$basename}.cmt.tar.gz&amp;File={$xpress_spec}.cmt">
							<xsl:value-of select="@spectrum"/>
						</A>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@spectrum"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>
				</xsl:text>
			</td>
			<td>
				<table cellpadding="2" bgcolor="white" 
					style="font-family: 'Courier New', Courier, mono; font-size: 10pt;">
					<TR>
						<xsl:if test="$Search_engine='SEQUEST'">
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='xcorr']/@value"/><xsl:text> </xsl:text></td>
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='deltacn']/@value"/><xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='deltacnstar']/@value='1'">*</xsl:if><xsl:text> </xsl:text></td>
							<td width="50" align="right">
								<xsl:value-of 
									select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='sprank']/@value"/><xsl:text> </xsl:text></td>
						</xsl:if>
						<xsl:if test="$Search_engine='MASCOT'">
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='ionscore']/@value"/><xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='star']/@value='1'">*</xsl:if><xsl:text> </xsl:text></td>
							<td width="50" align="right">
								<xsl:value-of 
									select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='identityscore']/@value"/>
								<xsl:text>
								</xsl:text>
							</td>
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='homologyscore']/@value"/><xsl:text> </xsl:text></td>
						</xsl:if>
						<xsl:if test="$Search_engine='PHENYX'">
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='zscore']/@value"/><xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='star']/@value='1'">*</xsl:if><xsl:text> </xsl:text></td>
							<td width="50" align="right">
								<xsl:value-of 
									select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='origScore']/@value"/>
								<xsl:text>
								</xsl:text>
							</td>
						</xsl:if>																			    
						<xsl:if test="$Search_engine='X! Tandem'">
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='hyperscore']/@value"/><xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='star']/@value='1'">*</xsl:if><xsl:text> </xsl:text></td>
							<td width="50" align="right">
								<xsl:value-of 
									select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='nextscore']/@value"/>
								<xsl:text>
								</xsl:text>
							</td>
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='expect']/@value"/><xsl:text> </xsl:text></td>
						</xsl:if>
						<xsl:if test="$Search_engine='COMET'">
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='dotproduct']/@value"/><xsl:text></xsl:text></td>
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='delta']/@value"/><xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank = '1']/search_score[@name='deltastar']/@value='1'">*</xsl:if><xsl:text> </xsl:text></td>
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='zscore']/@value"/><xsl:text> </xsl:text></td>
						</xsl:if>
						<xsl:if test="$Search_engine='PROBID'">
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='bays_score']/@value"/><xsl:text></xsl:text></td>
							<td width="50" align="right"><xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/pepx:search_score[@name='z_score']/@value"/><xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank = '1']/search_score[@name='deltastar']/@value='1'">*</xsl:if><xsl:text> </xsl:text></td>
						</xsl:if>
					</TR>
				</table>
			</td>
			<td align="RIGHT">
				<xsl:choose>
					<xsl:when test="$Search_engine='COMET'">
						<A TARGET="Win1" 
							HREF="{$cgi_home}plot-msms.cgi?MassType={$masstype}&amp;NumAxis=1&amp;{$PeptideMods2}Pep={$StrippedPeptide}&amp;Dta={$basename}/{$xpress_spec}.dta&amp;COMET=1">
							<nobr><xsl:value-of 
								select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@num_matched_ions"/>/<xsl:value-of 
								select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@tot_num_ions"/></nobr>
						</A>
					</xsl:when>
					<xsl:otherwise>
						<A TARGET="Win1" 
							HREF="{$cgi_home}plot-msms.cgi?MassType={$masstype}&amp;NumAxis=1&amp;{$PeptideMods2}Pep={$StrippedPeptide}&amp;Dta={$basename}/{$xpress_spec}.dta">
							<nobr><xsl:value-of 
								select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@num_matched_ions"/>/<xsl:value-of 
								select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@tot_num_ions"/></nobr>
						</A>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>
				</xsl:text>
			</td>
			<td>
				
				<!-- Print out the previous aa -->  	
				<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide_prev_aa">
					<xsl:value-of 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide_prev_aa"/>.</xsl:if>
				<A TARGET="Win1" 
					HREF="http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Web&amp;LAYOUT=TwoWindows&amp;AUTO_FORMAT=Semiauto&amp;ALIGNMENTS=50&amp;ALIGNMENT_VIEW=Pairwise&amp;CDD_SEARCH=on&amp;CLIENT=web&amp;COMPOSITION_BASED_STATISTICS=on&amp;DATABASE=nr&amp;DESCRIPTIONS=100&amp;ENTREZ_QUERY=(none)&amp;EXPECT=1000&amp;FILTER=L&amp;FORMAT_OBJECT=Alignment&amp;FORMAT_TYPE=HTML&amp;I_THRESH=0.005&amp;MATRIX_NAME=BLOSUM62&amp;NCBI_GI=on&amp;PAGE=Proteins&amp;PROGRAM=blastp&amp;SERVICE=plain&amp;SET_DEFAULTS.x=41&amp;SET_DEFAULTS.y=5&amp;SHOW_OVERVIEW=on&amp;END_OF_HTTPGET=Yes&amp;SHOW_LINKOUT=yes&amp;QUERY={$StrippedPeptide}">
					
						
		<!-- Start to see if there are any modified amino acids -->		
					<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info">
						<!-- if modification info is present then set some vars that can be re-used -->
							
								
						<xsl:if 
							test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@modified_peptide">
							<xsl:value-of 
								select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@modified_peptide"/>
						</xsl:if>
						<xsl:if 
							test="not(pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@modified_peptide)">
							<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_nterm_mass">n<font size="-2"><xsl:value-of 
									select="round(pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_nterm_mass)"/></font>
							</xsl:if>
							
							<!-- Print out the first amino acid -->	
									
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 1, 1)"/>
							
							<!-- Start to look and see if the modified peptide mass should be inserted -->	
							<xsl:variable name="All_modified_aa_nodes" select="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass"/>
									
							<xsl:if 
								test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass/@position='1'">
								<font size="-2">
									<xsl:value-of 
										select="round(pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass[@position='1']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 2, 1)"/>
							<xsl:if 
								test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass/@position='2'">
								<font size="-2">
									<xsl:value-of 
										select="round(pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/pepx:mod_aminoacid_mass[@position='2']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 3, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='3'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='3']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 4, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='4'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='4']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 5, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='5'"><font size="-2"><xsl:value-of 
										select="round($All_modified_aa_nodes[@position='5']/@mass)"/></font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 6, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='6'"><font size="-2"><xsl:value-of 
										select="round($All_modified_aa_nodes[@position='6']/@mass)"/></font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 7, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='7'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='7']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 8, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='8'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='8']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 9, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='9'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='9']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 10, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='10'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='10']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 11, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='11'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='11']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 12, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='12'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='12']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 13, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='13'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='13']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 14, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='14'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='14']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 15, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='15'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='15']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 16, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='16'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='16']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 17, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='17'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='17']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 18, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='18'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='18']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 19, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='19'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='19']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 20, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='20'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='20']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 21, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='21'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='21']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 22, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='22'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='22']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 23, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='23'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='23']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 24, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='24'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='24']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 25, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='25'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='25']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 26, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='26'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='26']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 27, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='27'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='27']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 28, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='28'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='28']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 29, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='29'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='29']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(search_result/pepx:search_hit[@hit_rank='1']/@peptide, 30, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='30'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='30']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 31, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='31'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='31']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 32, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='32'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='32']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 33, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='33'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='33']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 34, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='34'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='34']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 35, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='35'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='35']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 36, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='36'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='36']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 37, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='37'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='37']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 38, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='38'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='38']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 39, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='39'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='39']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 40, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='40'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='40']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 41, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='41'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='41']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 42, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='42'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='42']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 43, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='43'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='43']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 44, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='44'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='44']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 45, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='45'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='45']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 46, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='46'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='46']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 47, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='47'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='47']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 48, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='48'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='48']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 49, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='49'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@position='49']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:value-of 
								select="substring(pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide, 50, 1)"/>
							<xsl:if 
								test="$All_modified_aa_nodes/@position='50'">
								<font size="-2">
									<xsl:value-of 
										select="round($All_modified_aa_nodes[@positi1on='50']/@mass)"/>
								</font>
							</xsl:if>
							<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_cterm_mass">c<font size="-2"><xsl:value-of 
									select="round(pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info/@mod_cterm_mass)"/></font>
							</xsl:if>
						</xsl:if>
					</xsl:if>
					<xsl:if test="not(pepx:search_result/pepx:search_hit[@hit_rank='1']/pepx:modification_info)">
						<xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide"/>
					</xsl:if>
				</A>
				<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide_next_aa">.<xsl:value-of 
					select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide_next_aa"/></xsl:if>
				<xsl:text>
				</xsl:text>
			</td>
			<td>
				<A TARGET="Win1" 
					HREF="{$cgi_home}comet-fastadb.cgi?Db={$Database}&amp;Pep={pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide}&amp;MassType={$masstype}&amp;sample_enzyme={parent::node()/pepx:sample_enzyme/@name}&amp;min_ntt={$minntt}">
					<xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank = '1']/@protein"/>
				</A>
				<xsl:if test="pepx:search_result/pepx:search_hit[@hit_rank='1']/@num_tot_proteins &gt; 1">
					<xsl:if test="parent::node()/pepx:analysis_timestamp[analysis='database_refresh']">
						<xsl:text>
						</xsl:text>
						<A TARGET="Win1" 
							HREF="{$cgi_home}comet-fastadb.cgi?Db={$Database}&amp;Pep={pepx:search_result/pepx:search_hit[@hit_rank='1']/@peptide}&amp;MassType={$masstype}&amp;sample_enzyme={parent::node()/pepx:sample_enzyme/@name}&amp;min_ntt={$minntt}">
							+<xsl:value-of 
							select="number(pepx:search_result/pepx:search_hit[@hit_rank='1']/@num_tot_proteins)-1"/></A>
					</xsl:if>
				</xsl:if>
			</td>
			<td>
				<xsl:value-of select="pepx:search_result/pepx:search_hit[@hit_rank='1']/@num_tol_term"/>
				<xsl:text>
				</xsl:text>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>
