"use client";

import { useState, useEffect } from "react";
import { Bell, Send } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatRelativeTime } from "@/lib/utils";

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [showBroadcast, setShowBroadcast] = useState(false);
  const [broadcastTitle, setBroadcastTitle] = useState("");
  const [broadcastContent, setBroadcastContent] = useState("");
  const [sending, setSending] = useState(false);

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const res = await adminService.notifications.list({ page, limit: 15 });
      setNotifications(res.notifications);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchNotifications(); }, [page]);

  const handleBroadcast = async (e: React.FormEvent) => {
    e.preventDefault();
    setSending(true);
    try {
      await adminService.notifications.broadcast({ title: broadcastTitle, content: broadcastContent });
      setShowBroadcast(false);
      setBroadcastTitle("");
      setBroadcastContent("");
      fetchNotifications();
    } catch (err) {
      console.error(err);
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Notifications</h2>
          <p className="text-sm text-gray-500 mt-1">View platform notifications and broadcast messages.</p>
        </div>
        <button onClick={() => setShowBroadcast(true)} className="btn-primary">
          <Send size={16} /> Broadcast
        </button>
      </div>

      <div className="admin-card">
        <div className="divide-y divide-gray-50">
          {loading ? (
            <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
          ) : notifications.length === 0 ? (
            <div className="py-10 text-center text-gray-500 text-sm">No notifications yet.</div>
          ) : (
            notifications.map((notif) => (
              <div key={notif.id} className="px-5 py-4 hover:bg-gray-50/50 transition-colors">
                <div className="flex items-start gap-3">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${notif.isRead ? 'bg-gray-100' : 'bg-purple-50'}`}>
                    <Bell size={16} className={notif.isRead ? 'text-gray-400' : 'text-purple-600'} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900">{notif.title}</p>
                    <p className="text-xs text-gray-500 mt-0.5">{notif.content}</p>
                    <div className="flex items-center gap-3 mt-1.5">
                      <span className="text-[10px] text-gray-400">{formatRelativeTime(notif.createdAt)}</span>
                      <span className="text-[10px] text-gray-400">To: {notif.user?.name || 'All users'}</span>
                    </div>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {!loading && total > 0 && (
          <div className="flex justify-between items-center p-4 text-sm text-gray-500 border-t border-gray-100">
            <span>Showing {(page - 1) * 15 + 1} to {Math.min(page * 15, total)} of {total}</span>
            <div className="flex gap-2">
              <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Prev</button>
              <button disabled={page * 15 >= total} onClick={() => setPage(p => p + 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Next</button>
            </div>
          </div>
        )}
      </div>

      {/* Broadcast Modal */}
      {showBroadcast && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md shadow-modal animate-slide-in">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900">Broadcast Notification</h3>
              <button onClick={() => setShowBroadcast(false)} className="text-gray-400 hover:text-gray-600">✕</button>
            </div>
            <form onSubmit={handleBroadcast} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                <input required type="text" className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400" value={broadcastTitle} onChange={e => setBroadcastTitle(e.target.value)} placeholder="Notification title..." />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Content</label>
                <textarea required className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400 h-24 resize-none" value={broadcastContent} onChange={e => setBroadcastContent(e.target.value)} placeholder="Message content..." />
              </div>
              <div className="pt-4 flex justify-end gap-3">
                <button type="button" onClick={() => setShowBroadcast(false)} className="btn-secondary">Cancel</button>
                <button type="submit" disabled={sending} className="btn-primary">
                  {sending ? "Sending..." : "Send to All Users"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
