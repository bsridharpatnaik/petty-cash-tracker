import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const api = createApi({
  reducerPath: "api",
  baseQuery: fetchBaseQuery({
    baseUrl: `${process.env.REACT_APP_BASE_URL}`,
    prepareHeaders: (headers, { endpoint }) => {
      const user = JSON.parse(localStorage.getItem("user"));
      if (user?.token) {
        headers.set("Authorization", `Bearer ${user?.token}`);
      }
      headers.set("Cookie", "JSESSIONID=13CE0F53190CC7367FF06C791AC3FF27");
      if (endpoint === "uploadFile" || endpoint === "addSubFile") {
        return headers;
      } else if (endpoint === "downloadFile") {
        headers.set("Content-Type", "application/octet-stream");
      } else {
        headers.set("Content-Type", "application/json");
      }

      return headers;
    },
  }),
  endpoints: (builder) => ({
    createTransaction: builder.mutation({
      query: (data) => ({
        url: `/transaction`,
        method: "POST",
        body: data,
      }),
      invalidatesTags: ["Dashboard"],
    }),
    getExistingParty: builder.query({
      query: () => ({
        url: `/transaction/party`,
        method: "GET",
      }),
    }),
    getDashboardTransactionData: builder.query({
      query: ({ date, selectedOption }) => ({
        url: selectedOption
          ? `/dashboard/summary?dateOrMonth=${date}&party=${selectedOption}`
          : `/dashboard/summary?dateOrMonth=${date}`,
        method: "GET",
      }),
      providesTags: ["Dashboard"],
    }),

    uploadFile: builder.mutation({
      query: (formData) => ({
        url: `/file/upload`,
        method: "POST",
        body: formData,
      }),
    }),
    deleteTransaction: builder.mutation({
      query: (id) => ({
        url: `/transaction/${id}`,
        method: "DELETE",
      }),
      invalidatesTags: ["Dashboard"],
    }),
    updateTransaction: builder.mutation({
      query: ({ id, data }) => ({
        url: `/transaction/${id}`,
        method: "PUT",
        body: data,
      }),
      invalidatesTags: ["Dashboard"],
    }),
    getHistory: builder.query({
      query: () => ({
        url: `/history`,
        method: "GET",
      }),
    }),
    getDocumentationVault: builder.query({
      query: (id) => ({
        url: `/vault/folders?folderId=${id}`,
        method: "GET",
      }),
      providesTags: ["Folders"],
    }),
    addSubFolder: builder.mutation({
      query: ({ name, id }) => ({
        url: `/vault/folders?name=${name}&parentId=${id}`,
        method: "POST",
      }),
      invalidatesTags: ["Folders"],
    }),
    addSubFile: builder.mutation({
      query: (formData) => {
        return {
          url: `/vault/files`,
          method: "POST",
          body: formData,
        };
      },
      invalidatesTags: ["Folders"],
    }),
    deleteFolder: builder.mutation({
      query: (id) => {
        return {
          url: `/vault/folders/${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["Folders"],
    }),
    deleteFile: builder.mutation({
      query: (id) => {
        return {
          url: `/vault/files/${id}`,
          method: "DELETE",
        };
      },
      invalidatesTags: ["Folders"],
    }),
    downloadFile: builder.query({
      query: ({ id }) => ({
        url: `/vault/files/download/${id}`,
        responseType: "blob",
      }),
    }),
    getMonths: builder.query({
      query: ({ date, selectedOption }) => ({
        url: selectedOption
          ? `/dashboard/summary/grouped?startDate=${date}&party=${selectedOption}`
          : `/dashboard/summary/grouped?startDate=${date}`,
      }),
    }),
    getFiltered: builder.query({
      query: ({ startDate, endDate, selectedOption }) => ({
        url: selectedOption
          ? `/dashboard/summary/grouped?startDate=${startDate}&endDate=${endDate}&party=${selectedOption}`
          : `/dashboard/summary/grouped?startDate=${startDate}&endDate=${endDate}`,
      }),
    }),
  }),
});

export const {
  useCreateTransactionMutation,
  useGetExistingPartyQuery,
  useUploadFileMutation,
  useGetDashboardTransactionDataQuery,
  useDeleteTransactionMutation,
  useUpdateTransactionMutation,
  useGetHistoryQuery,
  useGetDocumentationVaultQuery,
  useAddSubFolderMutation,
  useAddSubFileMutation,
  useDeleteFolderMutation,
  useDeleteFileMutation,
  useDownloadFileQuery,
  useGetMonthsQuery,
  useGetFilteredQuery,
} = api;
