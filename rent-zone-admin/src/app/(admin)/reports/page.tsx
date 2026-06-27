"use client";

import { useState, useEffect } from "react";
import { Search, Filter, Eye, CheckCircle, XCircle } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, reportStatusColors } from "@/lib/utils";
import Link from "next/link";

export default function ReportsPage() {
  const [reports, setReports] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState("all");

  const fetchReports = async () => {
    setLoading(true);
    try {
      const res = await adminService.reports.list({ page, limit: 10, status: status !== "all" ? status : undefined });
      setReports(res.reports);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReports(); }, [page, status]);

  const handleResolve = async (id: string) => {
    try { await adminService.reports.resolve(id); fetchReports(); } catch (err) { console.error(err); }
  };

  const handleReject = async (id: string) => {
    try { await adminService.reports.reject(id); fetchReports(); } catch (err) { console.error(err); }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Reports</h2>
          <p className="text-sm text-gray-500 mt-1">Review and moderate user-submitted reports.</p>
        </div>
      </div>

      <div className="admin-card p-4">
        <div className="flex justify-end gap-3 mb-4">
          <select
            className="text-sm bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500/30"
            value={status}
            onChange={(e) => { setStatus(e.target.value); setPage(1); }}
          >
            <option value="all">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="valid">Valid</option>
            <option value="invalid">Invalid</option>
          </select>
        </div>

        <div className="overflow-x-auto">
          {loading ? (
            <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Reporter</th>
                  <th>Reported User</th>
                  <th>Reason</th>
                  <th>Status</th>
                  <th>Date</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {reports.map((report) => (
                  <tr key={report.id}>
                    <td className="font-medium text-gray-800">{report.reportedBy?.name}</td>
                    <td className="text-gray-700">{report.reportedUser?.name}</td>
                    <td><span className="badge badge-red capitalize">{report.reason}</span></td>
                    <td>
                      <span className={`badge ${reportStatusColors[report.status] || 'badge-gray'}`}>
                        {report.status}
                      </span>
                    </td>
                    <td className="text-gray-500 text-sm">{formatDate(report.createdAt)}</td>
                    <td className="text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Link href={`/reports/${report.id}`} className="p-1.5 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors">
                          <Eye size={16} />
                        </Link>
                        {report.status === "pending" && (
                          <>
                            <button onClick={() => handleResolve(report.id)} className="p-1.5 text-gray-400 hover:text-green-500 hover:bg-green-50 rounded-lg transition-colors" title="Mark Valid">
                              <CheckCircle size={16} />
                            </button>
                            <button onClick={() => handleReject(report.id)} className="p-1.5 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors" title="Mark Invalid">
                              <XCircle size={16} />
                            </button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
                {reports.length === 0 && (
                  <tr><td colSpan={6} className="text-center py-10 text-gray-500">No reports found.</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>

        {!loading && total > 0 && (
          <div className="flex justify-between items-center mt-4 text-sm text-gray-500 px-2">
            <span>Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, total)} of {total}</span>
            <div className="flex gap-2">
              <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Prev</button>
              <button disabled={page * 10 >= total} onClick={() => setPage(p => p + 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Next</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
