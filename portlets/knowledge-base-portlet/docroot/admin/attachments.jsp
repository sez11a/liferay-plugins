<%
/**
 * Copyright (c) 2000-2010 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ include file="/admin/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");

Article article = (Article)request.getAttribute(WebKeys.KNOWLEDGE_BASE_ARTICLE);

long resourcePrimKey = BeanParamUtil.getLong(article, request, "resourcePrimKey");

String dirName = ParamUtil.getString(request, "dirName");

String[] fileNames = DLServiceUtil.getFileNames(company.getCompanyId(), CompanyConstants.SYSTEM, dirName);
%>

<liferay-ui:tabs
	names="attachments"
/>

<aui:form method="post" name="fm">
	<aui:input name="fileName" type="hidden" />

	<liferay-ui:error exception="<%= DuplicateFileException.class %>" message="please-enter-a-unique-document-name" />
	<liferay-ui:error exception="<%= FileSizeException.class %>" message="please-enter-a-file-with-a-valid-file-size" />
	<liferay-ui:error exception="<%= NoSuchFileException.class %>" message="the-document-could-not-be-found" />

	<c:if test="<%= SessionErrors.contains(renderRequest, FileSizeException.class.getName()) %>">

		<%
		long fileMaxSize = GetterUtil.getLong(PrefsPropsUtil.getString(company.getCompanyId(), PropsKeys.DL_FILE_MAX_SIZE));
		%>

		<c:if test="<%= fileMaxSize > 0 %>">
			<div class="portlet-msg-info">
				<%= LanguageUtil.format(pageContext, "upload-documents-no-larger-than-x-k", String.valueOf(fileMaxSize / 1024), false) %>
			</div>
		</c:if>
	</c:if>

	<aui:fieldset>
		<liferay-ui:search-container
			delta="<%= fileNames.length %>"
			emptyResultsMessage="there-are-no-attachments"
			headerNames="attachment"
		>
			<liferay-ui:search-container-results
				results="<%= ListUtil.fromArray(fileNames) %>"
				total="<%= fileNames.length %>"
			/>

			<liferay-ui:search-container-row
				className="java.lang.String"
				modelVar="fileName"
				stringKey="<%= true %>"
			>
				<portlet:resourceURL id="attachment" var="rowURL">
					<portlet:param name="companyId" value="<%= String.valueOf(company.getCompanyId()) %>" />
					<portlet:param name="fileName" value="<%= fileName %>" />
				</portlet:resourceURL>

				<liferay-ui:search-container-column-text
					name="attachment"
				>
					<liferay-ui:icon
						image="clip"
						label="<%= true %>"
						message='<%= FileUtil.getShortFileName(fileName) + " (" + TextFormatter.formatKB(DLServiceUtil.getFileSize(company.getCompanyId(), CompanyConstants.SYSTEM, fileName), locale) + "k)" %>'
						method="get"
						url="<%= rowURL %>"
					/>
				</liferay-ui:search-container-column-text>

				<liferay-ui:search-container-column-text
					align="right"
				>

					<%
					String taglibURL = "javascript:" + renderResponse.getNamespace() + "deleteAttachment('" + UnicodeFormatter.toString(fileName) + "');";
					%>

					<liferay-ui:icon-delete
						label="<%= true %>"
						url="<%= taglibURL %>"
					/>
				</liferay-ui:search-container-column-text>
			</liferay-ui:search-container-row>

			<%
			String taglibOnChange = renderResponse.getNamespace() + "addAttachment();";
			%>

			<aui:input label="" name="file" onChange="<%= taglibOnChange %>" type="file" />

			<liferay-ui:search-iterator />
		</liferay-ui:search-container>
	</aui:fieldset>
</aui:form>

<liferay-util:buffer var="html">
	<liferay-util:include page="/admin/article_attachments.jsp" servletContext="<%= application %>" />
</liferay-util:buffer>

<aui:script>
	function <portlet:namespace />addAttachment() {
		document.<portlet:namespace />fm.enctype = "<%= ContentTypes.MULTIPART_FORM_DATA %>";
		submitForm(document.<portlet:namespace />fm, '<portlet:actionURL name="addAttachment"><portlet:param name="jspPage" value='<%= jspPageParams.get("attachments.jsp") %>' /><portlet:param name="redirect" value="<%= redirect %>" /><portlet:param name="resourcePrimKey" value="<%= String.valueOf(resourcePrimKey) %>" /><portlet:param name="dirName" value="<%= dirName %>" /></portlet:actionURL>');
	}

	function <portlet:namespace />deleteAttachment(fileName) {
		document.<portlet:namespace />fm.<portlet:namespace />fileName.value = fileName;
		submitForm(document.<portlet:namespace />fm, '<portlet:actionURL name="deleteAttachment"><portlet:param name="jspPage" value='<%= jspPageParams.get("attachments.jsp") %>' /><portlet:param name="redirect" value="<%= redirect %>" /><portlet:param name="resourcePrimKey" value="<%= String.valueOf(resourcePrimKey) %>" /><portlet:param name="dirName" value="<%= dirName %>" /></portlet:actionURL>');
	}

	opener.<portlet:namespace />updateAttachments("<%= UnicodeFormatter.toString(dirName) %>", "<%= UnicodeFormatter.toString(html) %>");
</aui:script>