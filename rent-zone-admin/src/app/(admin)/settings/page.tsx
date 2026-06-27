"use client";

import { useState } from "react";
import { Settings, Shield, Bell, Key, Save, AlertTriangle, CreditCard, LayoutTemplate } from "lucide-react";
import { cn } from "@/lib/utils";

const TABS = [
  { id: "general", label: "General Settings", icon: Settings },
  { id: "moderation", label: "Moderation", icon: Shield },
  { id: "notifications", label: "Notification Templates", icon: Bell },
  { id: "security", label: "Security & Access", icon: Key },
  { id: "billing", label: "Billing Settings", icon: CreditCard },
  { id: "appearance", label: "Appearance", icon: LayoutTemplate },
];

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState("general");
  const [loading, setLoading] = useState(false);
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    setLoading(true);
    setSaved(false);
    setTimeout(() => {
      setLoading(false);
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    }, 1000);
  };

  return (
    <div className="space-y-6 max-w-[1200px]">
      <div>
        <h2 className="text-xl font-bold text-gray-900">System Settings</h2>
        <p className="text-sm text-gray-500">Manage platform-wide configuration</p>
      </div>

      <div className="flex flex-col lg:flex-row gap-6 items-start">
        {/* Navigation Sidebar */}
        <div className="w-full lg:w-64 flex-shrink-0 space-y-1 admin-card p-2 sticky top-24">
          {TABS.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors text-left",
                  isActive ? "bg-purple-50 text-purple-700" : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                )}
              >
                <Icon size={18} className={isActive ? "text-purple-600" : "text-gray-400"} />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Content Area */}
        <div className="flex-1 admin-card min-h-[500px]">
          {/* Header */}
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 className="text-lg font-semibold text-gray-800">
              {TABS.find((t) => t.id === activeTab)?.label}
            </h3>
            <div className="flex items-center gap-3">
              {saved && <span className="text-sm text-emerald-600 font-medium">Changes saved!</span>}
              <button 
                onClick={handleSave} 
                disabled={loading}
                className="btn-primary"
              >
                {loading ? "Saving..." : <><Save size={16} /> Save Changes</>}
              </button>
            </div>
          </div>

          <div className="p-6">
            {activeTab === "general" && (
              <div className="space-y-6 max-w-2xl">
                <div className="space-y-4">
                  <h4 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Platform Info</h4>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <label className="text-sm font-medium text-gray-700">Platform Name</label>
                      <input type="text" defaultValue="Rent Zone" className="form-input" />
                    </div>
                    <div className="space-y-1.5">
                      <label className="text-sm font-medium text-gray-700">Support Email</label>
                      <input type="email" defaultValue="support@rentzone.com" className="form-input" />
                    </div>
                  </div>
                  
                  <div className="space-y-1.5">
                    <label className="text-sm font-medium text-gray-700">Platform Description</label>
                    <textarea 
                      rows={3} 
                      defaultValue="Rent Zone is India's premium clothing rental marketplace for men and women." 
                      className="form-input resize-none" 
                    />
                  </div>
                </div>

                <hr className="border-gray-100" />

                <div className="space-y-4">
                  <h4 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Operational Settings</h4>
                  
                  <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100">
                    <div>
                      <p className="font-medium text-gray-900 text-sm">Maintenance Mode</p>
                      <p className="text-xs text-gray-500 mt-0.5">Disable all non-admin access to the platform</p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input type="checkbox" className="sr-only peer" />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
                    </label>
                  </div>
                  
                  <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100">
                    <div>
                      <p className="font-medium text-gray-900 text-sm">Allow New Registrations</p>
                      <p className="text-xs text-gray-500 mt-0.5">Enable or disable new user signups</p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input type="checkbox" className="sr-only peer" defaultChecked />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
                    </label>
                  </div>
                </div>
              </div>
            )}

            {activeTab === "moderation" && (
              <div className="space-y-6 max-w-2xl">
                <div className="space-y-4">
                  <h4 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Automated Moderation</h4>
                  
                  <div className="space-y-1.5">
                    <label className="text-sm font-medium text-gray-700">Auto-Suspend Threshold (Reports)</label>
                    <p className="text-xs text-gray-500 mb-2">Automatically suspend users who receive this many valid reports.</p>
                    <input type="number" defaultValue="3" className="form-input w-32" />
                  </div>
                  
                  <div className="space-y-1.5 mt-4">
                    <label className="text-sm font-medium text-gray-700">Profanity Filter Level</label>
                    <select className="form-select max-w-xs">
                      <option>Strict (Block all flagged words)</option>
                      <option selected>Moderate (Block severe words)</option>
                      <option>Relaxed (Flag but don't block)</option>
                      <option>Off</option>
                    </select>
                  </div>
                </div>

                <hr className="border-gray-100" />

                <div className="space-y-4">
                  <h4 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Virtual Try-On Safety</h4>
                  
                  <div className="flex items-center justify-between p-4 bg-gray-50 rounded-xl border border-gray-100">
                    <div>
                      <p className="font-medium text-gray-900 text-sm">NSFW Image Detection</p>
                      <p className="text-xs text-gray-500 mt-0.5">Automatically scan generated images for NSFW content</p>
                    </div>
                    <label className="relative inline-flex items-center cursor-pointer">
                      <input type="checkbox" className="sr-only peer" defaultChecked />
                      <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
                    </label>
                  </div>
                </div>
              </div>
            )}

            {/* Placeholder for other tabs */}
            {activeTab !== "general" && activeTab !== "moderation" && (
              <div className="py-20 flex flex-col items-center justify-center text-center">
                <div className="w-16 h-16 bg-purple-50 rounded-2xl flex items-center justify-center mb-4 text-purple-400">
                  <Settings size={32} />
                </div>
                <p className="text-base font-semibold text-gray-900">Settings Section Under Construction</p>
                <p className="text-sm text-gray-500 mt-1 max-w-sm">
                  This settings module is being updated. Key configuration options will be available here soon.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
