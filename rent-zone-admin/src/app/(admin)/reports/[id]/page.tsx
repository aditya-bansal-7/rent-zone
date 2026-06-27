"use client";

import { use, useEffect, useState } from "react";
import Link from "next/link";
import { ArrowLeft, CheckCircle, XCircle, Flag } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatDate, formatDateTime, getInitials, reportStatusColors } from "@/lib/utils";

export default function ReportDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [report, setReport] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const fetchReport = async () => {
    try {
      const res = await adminService.reports.get(id);
      setReport(res);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchReport(); }, [id]);

  const handleResolve = async () => {
    try { await adminService.reports.resolve(id); fetchReport(); } catch (err) { console.error(err); }
  };

  const handleReject = async () => {
    try { await adminService.reports.reject(id); fetchReport(); } catch (err) { console.error(err); }
  };

  if (loading) return <div className="flex justify-center py-20"><div className="w-8 h-8 border-4 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>;
  if (!report) return <div className="py-20 text-center text-gray-500">Report not found</div>;

  return (
    <div className="space-y-5 max-w-[1000px]">
      <Link href="/reports" className="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-purple-600 transition-colors">
        <ArrowLeft size={15} /> Back to Reports
      </Link>

      <div className="admin-card p-6">
        <div className="flex justify-between items-start">
          <div>
            <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
              <Flag size={20} className="text-red-500" /> Report #{report.id.slice(-6)}
            </h2>
            <p className="text-sm text-gray-500 mt-1">Filed on {formatDateTime(report.createdAt)}</p>
          </div>
          <span className={`badge ${reportStatusColors[report.status] || 'badge-gray'}`}>{report.status}</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-8">
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-3 border-b pb-2">Reporter</h3>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold">
                {getInitials(report.reportedBy?.name || "U")}
              </div>
              <div>
                <Link href={`/users/${report.reportedBy?.id}`} className="font-semibold text-gray-900 hover:text-purple-600">{report.reportedBy?.name}</Link>
              </div>
            </div>
          </div>
          <div>
            <h3 className="text-sm font-semibold text-gray-900 mb-3 border-b pb-2">Reported User</h3>
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-red-100 text-red-700 flex items-center justify-center font-bold">
                {getInitials(report.reportedUser?.name || "U")}
              </div>
              <div>
                <Link href={`/users/${report.reportedUser?.id}`} className="font-semibold text-gray-900 hover:text-purple-600">{report.reportedUser?.name}</Link>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8">
          <h3 className="text-sm font-semibold text-gray-900 mb-2">Reason</h3>
          <span className="badge badge-red capitalize">{report.reason}</span>
        </div>

        <div className="mt-4">
          <h3 className="text-sm font-semibold text-gray-900 mb-2">Description</h3>
          <p className="text-sm text-gray-600 bg-gray-50 rounded-lg p-4">{report.description || "No additional details provided."}</p>
        </div>

        {report.status === "pending" && (
          <div className="mt-8 pt-6 border-t border-gray-100 flex gap-3">
            <button onClick={handleResolve} className="btn-primary gap-1.5">
              <CheckCircle size={16} /> Mark as Valid
            </button>
            <button onClick={handleReject} className="btn-secondary text-red-600 border-red-200 hover:bg-red-50 gap-1.5">
              <XCircle size={16} /> Mark as Invalid
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
